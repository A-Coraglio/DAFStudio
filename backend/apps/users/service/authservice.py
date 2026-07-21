from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta, timezone
import os
import re
import secrets

from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token

from apps.users.models.models import UserModel
from apps.users.models.ddo import UserDDO
from apps.users.service.dto import (
    RegisterInputDTO,
    LoginInputDTO,
    UpdateUserInputDTO,
    UserOutputDTO,
    TokenOutputDTO
)
from apps.users.exceptions.exceptions import (
    EmailAlreadyRegisteredException,
    GoogleAuthNotConfiguredException,
    InvalidCredentialsException,
    InvalidGoogleTokenException,
    InvalidPasswordChangeException,
    InvalidRegistrationException,
    UnauthorizedException,
    UserNotFoundException,
    UsernameAlreadyRegisteredException,
)
# Signing JWTs with a guessable secret would let anyone forge sessions, so a
# missing SECRET_KEY aborts startup instead of silently falling back.
SECRET_KEY = os.environ.get("SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError(
        "SECRET_KEY no está definida — agregala a backend/.env antes de arrancar"
    )
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
# Refresh tokens keep the session alive without re-login. 30 days matches the
# usual mobile-app expectation; rotation on every refresh limits replay. There
# is no server-side revocation list (stateless) — a leaked refresh token dies
# with its expiry or when the user deletes the account (lookup excludes them).
REFRESH_TOKEN_EXPIRE_DAYS = 30

# Comma-separated list of accepted Google OAuth client IDs (Web + Android +
# iOS — different platforms get different client ids from Google Cloud, but
# all of them issue id_tokens with the same `email` claim, so we accept any).
GOOGLE_OAUTH_CLIENT_IDS = [
    cid.strip()
    for cid in os.environ.get("GOOGLE_OAUTH_CLIENT_IDS", "").split(",")
    if cid.strip()
]

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Loose on purpose: enough to catch typos ("agus@", "agus.com"), not an
# attempt to validate every RFC corner. Real validation = email verification.
_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class AuthService():

    def _hash_password(self, password: str) -> str:
        return pwd_context.hash(password)

    def _validate_password(self, password: str) -> None:
        if len(password) < 8:
            raise InvalidRegistrationException(
                message="La contraseña debe tener al menos 8 caracteres"
            )
        # bcrypt silently truncates beyond 72 bytes — reject instead of
        # letting "the rest" of a long password stop counting.
        if len(password.encode("utf-8")) > 72:
            raise InvalidRegistrationException(
                message="La contraseña es demasiado larga (máximo 72 caracteres)"
            )

    def _validate_username(self, username: str) -> None:
        if len(username) < 3:
            raise InvalidRegistrationException(
                message="El nombre de usuario debe tener al menos 3 caracteres"
            )

    def _validate_email(self, email: str) -> None:
        if not _EMAIL_RE.match(email):
            raise InvalidRegistrationException(
                message="El email no es válido"
            )

    def _verify_password(self, plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)

    def _create_token(self, user_id: int) -> str:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        return jwt.encode({"sub": str(user_id), "exp": expire}, SECRET_KEY, algorithm=ALGORITHM)

    def _create_refresh_token(self, user_id: int) -> str:
        # type=refresh distingue este token del access: el auth_dependency lo
        # rechaza en endpoints normales (solo sirve en /auth/refresh/).
        expire = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
        return jwt.encode(
            {"sub": str(user_id), "exp": expire, "type": "refresh"},
            SECRET_KEY, algorithm=ALGORITHM,
        )

    def _token_pair(self, user_id: int) -> TokenOutputDTO:
        return TokenOutputDTO(
            access_token=self._create_token(user_id),
            refresh_token=self._create_refresh_token(user_id),
        )

    def _to_output_dto(self, user: UserDDO) -> UserOutputDTO:
        return UserOutputDTO(
            id=user.id,
            username=user.username,
            email=user.email,
            has_password=user.has_password,
        )

    async def users_register(self, data: RegisterInputDTO) -> UserOutputDTO:
        username = data.username.strip()
        email = data.email.strip()
        self._validate_username(username)
        self._validate_email(email)
        self._validate_password(data.password)
        if await UserModel().get_user_by_email(email=email):
            raise EmailAlreadyRegisteredException()
        # Username is unique in the DB too — checking here turns the raw
        # constraint violation (500) into a proper 409.
        if await UserModel().get_user_by_email_or_username(identifier=username):
            raise UsernameAlreadyRegisteredException()
        password_hash = self._hash_password(data.password)
        # User + empty player profile in one transaction; onboarding fills in
        # name, sport and level via PUT /api/players/me/.
        user = await UserModel().create_user_with_player(
            username=username,
            email=email,
            password_hash=password_hash,
        )
        return self._to_output_dto(user)

    async def users_login(self, data: LoginInputDTO) -> TokenOutputDTO:
        # Accept either the email or the username as the login identifier.
        user = await UserModel().get_user_by_email_or_username(
            identifier=data.login_id
        )
        if not user or not self._verify_password(data.password, user.password_hash):
            raise InvalidCredentialsException()
        return self._token_pair(user.id)

    async def users_login_with_google(self, id_token: str) -> TokenOutputDTO:
        """Verifies a Google id_token, finds-or-creates the matching auth_user,
        and emits our own JWT. We accept any client id in the configured allow
        list (Web / Android / iOS each get their own id from Google Cloud).
        """
        if not GOOGLE_OAUTH_CLIENT_IDS:
            raise GoogleAuthNotConfiguredException()

        try:
            # `audience=None` lets the library accept any aud claim; we then
            # check it manually against our allow list. This is cleaner than
            # looping and catching ValueError per client id.
            payload = google_id_token.verify_oauth2_token(
                id_token, google_requests.Request(), audience=None,
            )
        except ValueError as e:
            raise InvalidGoogleTokenException(message=f"Token inválido: {e}")

        if payload.get("aud") not in GOOGLE_OAUTH_CLIENT_IDS:
            raise InvalidGoogleTokenException(
                message="Token de Google emitido para una app no autorizada"
            )
        email = payload.get("email")
        if not email or not payload.get("email_verified"):
            raise InvalidGoogleTokenException(
                message="Tu cuenta de Google no tiene email verificado"
            )

        user = await UserModel().get_user_by_email(email=email)
        if user is None:
            # First sign-in for this user: provision an auth_user + player.
            # Random password = "unset"; the user can later set one via
            # /api/auth/users/{id}/ if they want to log in with email too.
            username = (
                payload.get("name")
                or payload.get("given_name")
                or email.split("@", 1)[0]
            )
            random_password_hash = self._hash_password(secrets.token_urlsafe(32))
            user = await UserModel().create_user_with_player(
                username=username,
                email=email,
                password_hash=random_password_hash,
                # Random hash the user never saw — has_password=False lets
                # them set a first password without knowing the current one.
                has_password=False,
            )

        return self._token_pair(user.id)

    async def users_refresh(self, refresh_token: str) -> TokenOutputDTO:
        """Exchanges a valid refresh token for a fresh access+refresh pair
        (rotation). Deleted accounts fail here because get_user_by_id
        filters them out."""
        try:
            payload = jwt.decode(refresh_token, SECRET_KEY, algorithms=[ALGORITHM])
        except JWTError:
            raise UnauthorizedException()
        if payload.get("type") != "refresh" or payload.get("sub") is None:
            raise UnauthorizedException()
        user = await UserModel().get_user_by_id(user_id=int(payload["sub"]))
        if user is None:
            raise UnauthorizedException()
        return self._token_pair(user.id)

    async def users_getter(self, user_id: int) -> UserOutputDTO:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise UserNotFoundException(message=f"No encontramos el usuario {user_id}")
        return self._to_output_dto(user)

    async def users_updater(self, user_id: int, data: UpdateUserInputDTO) -> UserOutputDTO:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise UserNotFoundException(message=f"No encontramos el usuario {user_id}")

        # Same format + uniqueness rules as registration — otherwise the DB
        # unique constraints surface as raw 500s instead of 409s.
        username = data.username.strip() if data.username else None
        email = data.email.strip() if data.email else None
        if username is not None and username != user.username:
            self._validate_username(username)
            if await UserModel().get_user_by_email_or_username(identifier=username):
                raise UsernameAlreadyRegisteredException()
        if email is not None and email != user.email:
            self._validate_email(email)
            existing = await UserModel().get_user_by_email(email=email)
            if existing and existing.id != user_id:
                raise EmailAlreadyRegisteredException()

        password_hash = None
        if data.password:
            # Changing the password requires proving you know the current one;
            # otherwise a leaked access token takes over the account for good.
            # Exception: Google-provisioned accounts (has_password=False) have
            # a random hash the user never saw — their FIRST set is free, and
            # update_user flips has_password to true.
            if user.has_password and (
                not data.current_password
                or not self._verify_password(
                    data.current_password, user.password_hash
                )
            ):
                raise InvalidPasswordChangeException()
            self._validate_password(data.password)
            password_hash = self._hash_password(data.password)

        updated = await UserModel().update_user(
            user_id=user_id,
            username=username,
            email=email,
            password_hash=password_hash
        )
        # If no fields were provided, the model returns None → keep user unchanged.
        return self._to_output_dto(updated or user)

    async def users_deleter(self, user_id: int) -> int:
        """Soft-delete: anonymizes the account and stamps deleted_at — the
        row survives so games, messages and other players' histories keep
        working. The scrambled hash makes the credentials unusable even if
        the login filters were ever bypassed."""
        scrambled = self._hash_password(secrets.token_urlsafe(32))
        deleted_id = await UserModel().soft_delete_user(
            user_id=user_id, scrambled_password_hash=scrambled
        )
        if not deleted_id:
            raise UserNotFoundException(message=f"No encontramos el usuario {user_id}")
        return deleted_id
