from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt

from apps.users.service.authservice import SECRET_KEY, ALGORITHM
from apps.users.models.models import UserModel
from apps.users.exceptions.exceptions import (
    AccountBannedException,
    UnauthorizedException,
)

_bearer_scheme = HTTPBearer(auto_error=True)


async def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> int:
    try:
        payload = jwt.decode(
            credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM]
        )
        subject = payload.get("sub")
        # A refresh token is NOT an access token — it only works against
        # /auth/refresh/. Without this check a leaked 30-day refresh token
        # would grant direct API access.
        if subject is None or payload.get("type") == "refresh":
            raise UnauthorizedException(message="Sesión inválida. Ingresá de nuevo")
        user_id = int(subject)
    except JWTError:
        raise UnauthorizedException(message="Tu sesión expiró. Ingresá de nuevo")

    # Expulsión inmediata (decisión 2026-07-21): cada request valida la
    # cuenta en DB — un ban o borrado corta la sesión al instante, no a los
    # 60 min del token. Cuesta un lookup por PK por request.
    user = await UserModel().get_user_by_id(user_id=user_id)
    if user is None:
        raise UnauthorizedException(message="Sesión inválida. Ingresá de nuevo")
    if user.banned_at is not None:
        raise AccountBannedException()
    return user_id
