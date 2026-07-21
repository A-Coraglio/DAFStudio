from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy
from pydantic import BaseModel, Field

from apps.games.models import GeneralModel
from apps.common.exceptions.exceptions import (
    AppException,
    DatabaseException,
    NotFoundException,
)
from apps.games.exceptions.exceptions import GameStateException


class GamePlayerDDO(BaseModel):
    game_id: int
    player_id: int
    # Chosen slot (0..max_players-1); first half = home side. None = joined
    # without picking a spot (matchmaking / legacy rows).
    position: int | None = Field(default=None)
    created_at: datetime


def _row_to_ddo(row) -> GamePlayerDDO:
    return GamePlayerDDO(
        game_id=row["game_id"],
        player_id=row["player_id"],
        position=row["position"],
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
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    async def list_players_by_game_ids(
        self, game_ids: list[int]
    ) -> dict[int, list[GamePlayerDDO]]:
        """Bulk rosters keyed by game_id, join order preserved. Backs the
        stats/history endpoints so outcomes for N games cost one query
        instead of N."""
        if not game_ids:
            return {}
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE game_id = ANY($1::int[]) ORDER BY created_at"
            )
            try:
                results = await connection.fetch(query, game_ids)
                rosters: dict[int, list[GamePlayerDDO]] = {}
                for r in results:
                    rosters.setdefault(int(r["game_id"]), []).append(
                        _row_to_ddo(r)
                    )
                return rosters
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def remove_all_for_game(self, game_id: int) -> int:
        """Clears the roster of a game — used when matchmaking cancels a
        proposed game (reject/expire) so no players stay linked to it."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"DELETE FROM {self.__table_name__} WHERE game_id = $1"
            try:
                result = await connection.execute(query, game_id)
                return int(result.split(" ")[-1])
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    async def taken_positions(self, game_id: int) -> set[int]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT position FROM {self.__table_name__} "
                "WHERE game_id = $1 AND position IS NOT NULL"
            )
            try:
                results = await connection.fetch(query, game_id)
                return {int(r["position"]) for r in results}
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def add_player(
        self,
        game_id: int,
        player_id: int,
        position: int | None = None,
    ) -> GamePlayerDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(game_id, player_id, position) "
                "VALUES ($1, $2, $3) RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, game_id, player_id, position
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def join_atomic(
        self,
        game_id: int,
        player_id: int,
        position: int | None = None,
    ) -> bool:
        """Single-transaction join. Locks the game row (FOR UPDATE) so two
        concurrent joins can't overbook the roster or take the same position
        slot — validations and the insert see a frozen state. Also flips the
        game to 'full' inside the same transaction when the last slot fills.
        Returns True if this join filled the game."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    game = await connection.fetchrow(
                        "SELECT status, max_players FROM game "
                        "WHERE id = $1 FOR UPDATE",
                        game_id,
                    )
                    if game is None:
                        raise NotFoundException(
                            message=f"No encontramos el partido {game_id}"
                        )
                    if game["status"] != "open":
                        raise GameStateException(
                            message="Ya no es posible unirse a este partido"
                        )
                    already = await connection.fetchrow(
                        f"SELECT 1 FROM {self.__table_name__} "
                        "WHERE game_id = $1 AND player_id = $2",
                        game_id, player_id,
                    )
                    if already:
                        raise GameStateException(
                            message="Ya estás anotado en este partido"
                        )
                    count = await connection.fetchval(
                        f"SELECT COUNT(*) FROM {self.__table_name__} "
                        "WHERE game_id = $1",
                        game_id,
                    )
                    if count >= game["max_players"]:
                        raise GameStateException(
                            message="El partido está completo"
                        )
                    if position is not None:
                        if position >= game["max_players"]:
                            raise GameStateException(
                                message="Esa posición no existe en este partido",
                                error_code=400,
                            )
                        taken = await connection.fetchrow(
                            f"SELECT 1 FROM {self.__table_name__} "
                            "WHERE game_id = $1 AND position = $2",
                            game_id, position,
                        )
                        if taken:
                            raise GameStateException(
                                message="Esa posición ya está ocupada"
                            )
                    await connection.execute(
                        f"INSERT INTO {self.__table_name__} "
                        "(game_id, player_id, position) "
                        "VALUES ($1, $2, $3)",
                        game_id, player_id, position,
                    )
                    filled = count + 1 >= game["max_players"]
                    if filled:
                        await connection.execute(
                            "UPDATE game SET status = 'full' WHERE id = $1",
                            game_id,
                        )
                    return filled
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def move_atomic(
        self, game_id: int, player_id: int, position: int
    ) -> None:
        """Re-position an already-joined player. Same locking discipline as
        join_atomic: the game row lock freezes the board so two concurrent
        moves (or a move racing a join) can't land on the same slot. Works
        while the game is open OR full — moving doesn't change the roster."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    game = await connection.fetchrow(
                        "SELECT status, max_players FROM game "
                        "WHERE id = $1 FOR UPDATE",
                        game_id,
                    )
                    if game is None:
                        raise NotFoundException(
                            message=f"No encontramos el partido {game_id}"
                        )
                    if game["status"] not in ("open", "full"):
                        raise GameStateException(
                            message="Ya no es posible cambiar de posición en este partido"
                        )
                    mine = await connection.fetchrow(
                        f"SELECT position FROM {self.__table_name__} "
                        "WHERE game_id = $1 AND player_id = $2",
                        game_id, player_id,
                    )
                    if mine is None:
                        raise GameStateException(
                            message="No estás anotado en este partido"
                        )
                    if position >= game["max_players"]:
                        raise GameStateException(
                            message="Esa posición no existe en este partido",
                            error_code=400,
                        )
                    if mine["position"] == position:
                        return
                    taken = await connection.fetchrow(
                        f"SELECT 1 FROM {self.__table_name__} "
                        "WHERE game_id = $1 AND position = $2 "
                        "AND player_id <> $3",
                        game_id, position, player_id,
                    )
                    if taken:
                        raise GameStateException(
                            message="Esa posición ya está ocupada"
                        )
                    await connection.execute(
                        f"UPDATE {self.__table_name__} SET position = $3 "
                        "WHERE game_id = $1 AND player_id = $2",
                        game_id, player_id, position,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")
