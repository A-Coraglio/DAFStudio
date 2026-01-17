from apps.games.models import GeneralModel
from apps.games.models.ddo import UserDDO
from typing import cast
from asyncpg.pool import PoolConnectionProxy

class UserModel(GeneralModel):
    __table_name__ = "users"
    async def list_users(self) -> list[UserDDO]:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"SELECT * from {self.__table_name__}"

            results = await connection.fetch(query)

            return [ UserDDO(id=i["id"], name=i["name"]) for i in results]
        
