from apps.games.models import GeneralModel
from apps.games.models.ddo import GameDDO
from typing import cast
from asyncpg.pool import PoolConnectionProxy

from apps.games.exceptions.exceptions import DatbaseException, NotFoundException

class GamesModel(GeneralModel):
    __table_name__ = "game"
    async def list_games(self) -> list[GameDDO]:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"SELECT * from {self.__table_name__}"
            try:
                results = await connection.fetch(query)
                return [GameDDO(id=i["id"], name=i["name"], sport_id=i["sport_id"], organizer_id=i["organizer_id"], max_players=i["max_players"], created_at=i["created_at"]) for i in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
    async def get_game_by_id(self, game_id: int) -> GameDDO:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"SELECT * from {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, game_id)

                if result is not None:
                    return GameDDO(id=result["id"], name=result["name"], sport_id=result["sport_id"], organizer_id=result["organizer_id"], max_players=result["max_players"], created_at=result["created_at"])
                
                raise NotFoundException(message=f"Game with the id : {game_id} not found")
            except NotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create_game(self, name: str) -> GameDDO:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"INSERT INTO {self.__table_name__} (name) VALUES ($1) RETURNING *"
            try:
                result = await connection.fetchrow(query, name)
                return GameDDO(id=result["id"], name=result["name"], sport_id=result["sport_id"], organizer_id=result["organizer_id"], max_players=result["max_players"], created_at=result["created_at"])
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def update_game(self, game_id: int, name: str) -> GameDDO:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"UPDATE {self.__table_name__} SET name = $1 WHERE id = $2 RETURNING *"
            try:

                result = await connection.fetchrow(query, name, game_id)
                if result is not None:
                    return GameDDO(id=result["id"], name=result["name"], sport_id=result["sport_id"], organizer_id=result["organizer_id"], max_players=result["max_players"], created_at=result["created_at"])
                raise NotFoundException(message=f"Game with the id : {game_id} not found")
            except NotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def delete_game(self, game_id: int) -> int:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = f"DELETE FROM {self.__table_name__} WHERE id = $1 RETURNING id"
            try:

                result = await connection.fetchrow(query, game_id)
                if result is not None:
                    return result["id"]
                raise NotFoundException(message=f"Game with the id : {game_id} not found")
            except NotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
