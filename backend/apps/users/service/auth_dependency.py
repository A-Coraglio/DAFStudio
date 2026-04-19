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
        if subject is None:
            raise UnauthorizedException(message="Invalid token")
        return int(subject)
    except JWTError:
        raise UnauthorizedException(message="Invalid or expired token")
