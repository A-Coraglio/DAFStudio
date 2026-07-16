from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy
from pydantic import BaseModel

from apps.games.models import GeneralModel
from apps.common.exceptions.exceptions import DatabaseException


class GameResultConfirmationDDO(BaseModel):
    game_id: int
    player_id: int
    reported_home: int
    reported_away: int
    sets: str | None = None
    created_at: datetime


def _row_to_ddo(row) -> GameResultConfirmationDDO:
    return GameResultConfirmationDDO(
        game_id=row["game_id"],
        player_id=row["player_id"],
        reported_home=row["reported_home"],
        reported_away=row["reported_away"],
        sets=row.get("sets"),
        created_at=row["created_at"],
    )


class GameResultConfirmationModel(GeneralModel):
    __table_name__ = "game_result_confirmation"

    async def list_confirmations(
        self, game_id: int
    ) -> list[GameResultConfirmationDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE game_id = $1"
            try:
                results = await connection.fetch(query, game_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def upsert_confirmation(
        self,
        game_id: int,
        player_id: int,
        reported_home: int,
        reported_away: int,
        sets: str | None = None,
    ) -> GameResultConfirmationDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            # Players can change their vote before the game finalizes.
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(game_id, player_id, reported_home, reported_away, sets) "
                "VALUES ($1, $2, $3, $4, $5) "
                "ON CONFLICT (game_id, player_id) DO UPDATE SET "
                "reported_home = EXCLUDED.reported_home, "
                "reported_away = EXCLUDED.reported_away, "
                "sets = EXCLUDED.sets, "
                "created_at = now() "
                "RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, game_id, player_id, reported_home, reported_away, sets
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
