from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta, timezone
import os
from apps.users.models.models import UserModel
from apps.users.models.ddo import UserDDO
from apps.users.service.dto import (
    RegisterInputDTO,
    LoginInputDTO,
    UpdateUserInputDTO,
    UserOutputDTO,
    TokenOutputDTO
)

SECRET_KEY = os.environ.get("SECRET_KEY", "changeme")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

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
            raise ValueError("La contraseña ya existe wachin")
        password_hash = self._hash_password(data.password)
        user = await UserModel().create_user(
            username=data.username,
            email=data.email,
            password_hash=password_hash
        )
        return self._to_output_dto(user)

    async def users_login(self, data: LoginInputDTO) -> TokenOutputDTO:
        user = await UserModel().get_user_by_email(email=data.email)
        if not user or not self._verify_password(data.password, user.password_hash):
            raise ValueError("Usuario o contraseña incorrectos, pone algo bien")
        token = self._create_token(user.id)
        return TokenOutputDTO(access_token=token)

    async def users_getter(self, user_id: int) -> UserOutputDTO:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise ValueError("User not found")
        return self._to_output_dto(user)

    async def users_updater(self, user_id: int, data: UpdateUserInputDTO) -> UserOutputDTO:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise ValueError("User not found")

        password_hash = self._hash_password(data.password) if data.password else None

        updated = await UserModel().update_user(
            user_id=user_id,
            username=data.username,
            email=data.email,
            password_hash=password_hash
        )
        if not updated:
            raise ValueError("Nothing to update")
        return self._to_output_dto(updated)

    async def users_deleter(self, user_id: int) -> int:
        user = await UserModel().get_user_by_id(user_id=user_id)
        if not user:
            raise ValueError("User not found")
        deleted_id = await UserModel().delete_user(user_id=user_id)
        if not deleted_id:
            raise ValueError("Could not delete user")
        return deleted_id
    
    