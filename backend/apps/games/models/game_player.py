from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy
from pydantic import BaseModel, Field

from apps.games.models import GeneralModel
from apps.games.exceptions.exceptions import DatbaseException


class GamePlayerDDO(BaseModel):
    game_id: int
    player_id: int
    team_id: int | None = Field(default=None)
    created_at: datetime


def _row_to_ddo(row) -> GamePlayerDDO:
    return GamePlayerDDO(
        game_id=row["game_id"],
        player_id=row["player_id"],
        team_id=row["team_id"],
        created_at=row["created_at"],
    )


class GamePlayerModel(GeneralModel):
    __table_name__ = "game_player"

    async def list_players(self, game_id: int) -> list[GamePlayerDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE game_id = $1 ORDER BY created_at"
            )
            try:
                results = await connection.fetch(query, game_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def count_players(self, game_id: int) -> int:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT COUNT(*) AS c FROM {self.__table_name__} WHERE game_id = $1"
            )
            try:
                result = await connection.fetchrow(query, game_id)
                return int(result["c"]) if result else 0
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def counts_by_game_ids(
        self, game_ids: list[int]
    ) -> dict[int, int]:
        """Bulk variant used by list_games so we don't issue N+1 queries to
        show "3/10 jugadores" on every card."""
        if not game_ids:
            return {}
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT game_id, COUNT(*) AS c FROM {self.__table_name__} "
                "WHERE game_id = ANY($1::int[]) GROUP BY game_id"
            )
            try:
                results = await connection.fetch(query, game_ids)
                return {int(r["game_id"]): int(r["c"]) for r in results}
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def is_player_in_game(self, game_id: int, player_id: int) -> bool:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT 1 FROM {self.__table_name__} "
                "WHERE game_id = $1 AND player_id = $2"
            )
            try:
                result = await connection.fetchrow(query, game_id, player_id)
                return result is not None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def add_player(
        self,
        game_id: int,
        player_id: int,
        team_id: int | None = None,
    ) -> GamePlayerDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(game_id, player_id, team_id) "
                "VALUES ($1, $2, $3) RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, game_id, player_id, team_id)
                return _row_to_ddo(result)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def remove_player(self, game_id: int, player_id: int) -> bool:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"DELETE FROM {self.__table_name__} "
                "WHERE game_id = $1 AND player_id = $2 RETURNING player_id"
            )
            try:
                result = await connection.fetchrow(query, game_id, player_id)
                return result is not None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
