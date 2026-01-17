from apps.games.models import GeneralModel
from apps.games.models.ddo import UserDDO


class UserModel(GeneralModel):
    __table_name__ = "users"
    async def list_users(self) -> UserDDO:
        async with self.get_db_connection() as connection:

            query = f"SELECT * from {self.__table_name__}"

            results = await connection.fetch(query)

            return [ UserDDO(id=i["id"], name=i["name"]) for i in results]
        
