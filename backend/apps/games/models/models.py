from apps.games.models import GeneralModel
from apps.games.models.ddo import GameDDO
from typing import cast
from asyncpg.pool import PoolConnectionProxy

class GamesModel(GeneralModel):
    __table_name__ = "game"
    async def list_games(self) -> list[GameDDO]:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"SELECT * from {self.__table_name__}"

            results = await connection.fetch(query)
            return [GameDDO(id=i["id"], name=i["name"]) for i in results]