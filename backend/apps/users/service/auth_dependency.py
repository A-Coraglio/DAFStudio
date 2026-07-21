from fastapi import Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt

from apps.users.service.authservice import SECRET_KEY, ALGORITHM
from apps.users.exceptions.exceptions import UnauthorizedException

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
        return int(subject)
    except JWTError:
        raise UnauthorizedException(message="Tu sesión expiró. Ingresá de nuevo")
