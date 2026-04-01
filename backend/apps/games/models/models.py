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
            return [GameDDO(id=i["id"], name=i["name"], sport_id=i["sport_id"], organizer_id=i["organizer_id"], max_players=i["max_players"], created_at=i["created_at"]) for i in results]
        
    async def get_game_by_id(self, game_id: int) -> GameDDO | None:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"SELECT * from {self.__table_name__} WHERE id = $1"

            result = await connection.fetchrow(query, game_id)
            if result:
                return GameDDO(id=result["id"], name=result["name"], sport_id=result["sport_id"], organizer_id=result["organizer_id"], max_players=result["max_players"], created_at=result["created_at"])
            return None
        
    async def create_game(self, name: str) -> GameDDO:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"INSERT INTO {self.__table_name__} (name) VALUES ($1) RETURNING *"

            result = await connection.fetchrow(query, name)
            return GameDDO(id=result["id"], name=result["name"], sport_id=result["sport_id"], organizer_id=result["organizer_id"], max_players=result["max_players"], created_at=result["created_at"])
        
    async def update_game(self, game_id: int, name: str) -> GameDDO | None:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"UPDATE {self.__table_name__} SET name = $1 WHERE id = $2 RETURNING *"

            result = await connection.fetchrow(query, name, game_id)
            if result:
                return GameDDO(id=result["id"], name=result["name"], sport_id=result["sport_id"], organizer_id=result["organizer_id"], max_players=result["max_players"], created_at=result["created_at"])
            return None
        
    async def delete_game(self, game_id: int) -> int | None:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"DELETE FROM {self.__table_name__} WHERE id = $1 RETURNING id"

            result = await connection.fetchrow(query, game_id)
            if result:
                return result["id"]
            return None