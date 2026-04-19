from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.matchmaking.models import GeneralModel
from apps.matchmaking.models.ddo import MatchmakingTicketDDO
from apps.matchmaking.exceptions.exceptions import TicketNotFoundException
from apps.games.exceptions.exceptions import DatbaseException


# States considered "active" — a user with a ticket in any of these is
# currently committed to a matchmaking attempt and should not be able to
# queue again.
ACTIVE_STATES = ("waiting", "proposed", "accepted")


def _row_to_ddo(row) -> MatchmakingTicketDDO:
    return MatchmakingTicketDDO(
        id=row["id"],
        user_id=row["user_id"],
        sport_id=row["sport_id"],
        max_radius_km=row["max_radius_km"],
        origin_lat=row["origin_lat"],
        origin_lon=row["origin_lon"],
        window_start=row["window_start"],
        window_end=row["window_end"],
        status=row["status"],
        matched_game_id=row["matched_game_id"],
        created_at=row["created_at"],
    )


class MatchmakingTicketModel(GeneralModel):
    __table_name__ = "matchmaking_ticket"

    async def get_ticket_by_id(self, ticket_id: int) -> MatchmakingTicketDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, ticket_id)
                if result is None:
                    raise TicketNotFoundException(
                        message=f"Ticket {ticket_id} not found"
                    )
                return _row_to_ddo(result)
            except TicketNotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def get_active_ticket_for_user(
        self, user_id: int
    ) -> MatchmakingTicketDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                f"WHERE user_id = $1 AND status = ANY($2::text[]) "
                "ORDER BY created_at DESC LIMIT 1"
            )
            try:
                result = await connection.fetchrow(
                    query, user_id, list(ACTIVE_STATES)
                )
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def list_waiting_for_sport(
        self, sport_id: int
    ) -> list[MatchmakingTicketDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE sport_id = $1 AND status = 'waiting' "
                "AND window_end > now() "
                "ORDER BY created_at ASC"
            )
            try:
                results = await connection.fetch(query, sport_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def list_by_game(
        self, matched_game_id: int
    ) -> list[MatchmakingTicketDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE matched_game_id = $1"
            )
            try:
                results = await connection.fetch(query, matched_game_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create_ticket(
        self,
        user_id: int,
        sport_id: int,
        max_radius_km: float,
        origin_lat: float,
        origin_lon: float,
        window_start: datetime,
        window_end: datetime,
    ) -> MatchmakingTicketDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(user_id, sport_id, max_radius_km, origin_lat, origin_lon, "
                " window_start, window_end, status) "
                "VALUES ($1, $2, $3, $4, $5, $6, $7, 'waiting') RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, user_id, sport_id, max_radius_km,
                    origin_lat, origin_lon, window_start, window_end,
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def set_status(
        self,
        ticket_id: int,
        status: str,
        matched_game_id: int | None = None,
    ) -> MatchmakingTicketDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            if matched_game_id is not None:
                query = (
                    f"UPDATE {self.__table_name__} "
                    "SET status = $1, matched_game_id = $2 "
                    "WHERE id = $3 RETURNING *"
                )
                values = [status, matched_game_id, ticket_id]
            else:
                query = (
                    f"UPDATE {self.__table_name__} "
                    "SET status = $1 WHERE id = $2 RETURNING *"
                )
                values = [status, ticket_id]
            try:
                result = await connection.fetchrow(query, *values)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def reopen_group(self, matched_game_id: int) -> int:
        """Called when the acceptance phase of a proposed match collapses —
        puts non-rejected tickets back to 'waiting' so they try again."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"UPDATE {self.__table_name__} "
                "SET status = 'waiting', matched_game_id = NULL "
                "WHERE matched_game_id = $1 AND status IN ('proposed', 'accepted') "
                "RETURNING id"
            )
            try:
                results = await connection.fetch(query, matched_game_id)
                return len(results)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
