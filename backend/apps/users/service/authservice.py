from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta, timezone
import os
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
    UserNotFoundException,
)
from apps.players.models.models import PlayerModel

SECRET_KEY = os.environ.get("SECRET_KEY", "changeme")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# Comma-separated list of accepted Google OAuth client IDs (Web + Android +
# iOS — different platforms get different client ids from Google Cloud, but
# all of them issue id_tokens with the same `email` claim, so we accept any).
GOOGLE_OAUTH_CLIENT_IDS = [
    cid.strip()
    for cid in os.environ.get("GOOGLE_OAUTH_CLIENT_IDS", "").split(",")
    if cid.strip()
]

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class AuthService():

    def _hash_password(self, password: str) -> str:
        return pwd_context.hash(password)

    def _verify_password(self, plain: str, hashed: str) -> bool:
        return pwd_context.verify(plain, hashed)

    def _create_token(self, user_id: int) -> str:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        return jwt.encode({"sub": str(user_id), "exp": expire}, SECRET_KEY, algorithm=ALGORITHM)

    def _to_output_dto(self, user: UserDDO) -> UserOutputDTO:
        return UserOutputDTO(id=user.id, username=user.username, email=user.email)

    async def users_register(self, data: RegisterInputDTO) -> UserOutputDTO:
        existing = await UserModel().get_user_by_email(email=data.email)
        if existing:
            raise EmailAlreadyRegisteredException()
        password_hash = self._hash_password(data.password)
        user = await UserModel().create_user(
            username=data.username,
            email=data.email,
            password_hash=password_hash
        )
        # Every auth_user gets an empty player profile so the user can
        # immediately use the app. The onboarding step fills in name, sport,
        # level via PUT /api/players/me/.
        await PlayerModel().create_player(user_id=user.id)
        return self._to_output_dto(user)

    async def users_login(self, data: LoginInputDTO) -> TokenOutputDTO:
        # Accept either the email or the username as the login identifier.
        user = await UserModel().get_user_by_email_or_username(
            identifier=data.login_id
        )
        if not user or not self._verify_password(data.password, user.password_hash):
            raise InvalidCredentialsException()
        token = self._create_token(user.id)
        return TokenOutputDTO(access_token=token)

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
            user = await UserModel().create_user(
                username=username,
                email=email,
                password_hash=random_password_hash,
            )
            await PlayerModel().create_player(user_id=user.id)

        token = self._create_token(user.id)
        return TokenOutputDTO(access_token=token)

    async def users_getter(self, user_id: int) -> UserOutputDTO:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise UserNotFoundException(message=f"User with id {user_id} not found")
        return self._to_output_dto(user)

    async def users_updater(self, user_id: int, data: UpdateUserInputDTO) -> UserOutputDTO:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise UserNotFoundException(message=f"User with id {user_id} not found")

        password_hash = self._hash_password(data.password) if data.password else None

        updated = await UserModel().update_user(
            user_id=user_id,
            username=data.username,
            email=data.email,
            password_hash=password_hash
        )
        # If no fields were provided, the model returns None → keep user unchanged.
        return self._to_output_dto(updated or user)

    async def users_deleter(self, user_id: int) -> int:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise UserNotFoundException(message=f"User with id {user_id} not found")
        deleted_id = await UserModel().delete_user(user_id=user_id)
        if not deleted_id:
            raise UserNotFoundException(message=f"User with id {user_id} not found")
        return deleted_id
