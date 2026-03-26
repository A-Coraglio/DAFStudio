from apps.users.models.ddo import UserDDO
from apps.users.models import GeneralModel
from typing import cast
from asyncpg.pool import PoolConnectionProxy

class UserModel(GeneralModel):
    __table_name__ = "auth_user"
    async def get_user_by_email(self, email: str) -> UserDDO | None:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"SELECT * from {self.__table_name__} WHERE email = $1"
            
            result = await connection.fetchrow(query, email)
            if result:
                return UserDDO(
                    id=result["id"],
                    username=result["username"],
                    email=result["email"],
                    password_hash=result["password_hash"],
                    created_at=result["created_at"]
                )
            return None

    async def get_user_by_id(self, user_id: int) -> UserDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            result = await connection.fetchrow(query, user_id)
            if result:
                return UserDDO(id=result["id"], username=result["username"], email=result["email"], password_hash=result["password_hash"], created_at=result["created_at"])
            return None


    async def create_user(self, username: str, email: str, password_hash: str) -> UserDDO:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"INSERT INTO {self.__table_name__} (username, email, password_hash) VALUES ($1, $2, $3) RETURNING *"

            result = await connection.fetchrow(query, username, email, password_hash)
            return UserDDO(
                id=result["id"],
                username=result["username"],
                email=result["email"],
                password_hash=result["password_hash"],
                created_at=result["created_at"]
            )   
        
    async def update_user(self, user_id: int, username: str | None = None, email: str | None = None, password_hash: str | None = None) -> UserDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            # Construye dinámicamente solo los campos que se quieren actualizar
            fields = []
            values = []
            idx = 1
            if username is not None:
                fields.append(f"username = ${idx}")
                values.append(username)
                idx += 1
            if email is not None:
                fields.append(f"email = ${idx}")
                values.append(email)
                idx += 1
            if password_hash is not None:
                fields.append(f"password_hash = ${idx}")
                values.append(password_hash)
                idx += 1

            if not fields:
                return None  # nada que actualizar

            values.append(user_id)
            query = f"UPDATE {self.__table_name__} SET {', '.join(fields)} WHERE id = ${idx} RETURNING *"
            result = await connection.fetchrow(query, *values)
            if result:
                return UserDDO(id=result["id"], username=result["username"], email=result["email"], password_hash=result["password_hash"], created_at=result["created_at"])
            return None

    async def delete_user(self, user_id: int) -> int | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"DELETE FROM {self.__table_name__} WHERE id = $1 RETURNING id"
            result = await connection.fetchrow(query, user_id)
            if result:
                return result["id"]
            return None