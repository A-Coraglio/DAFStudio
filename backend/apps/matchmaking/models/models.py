from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.matchmaking.models import GeneralModel
from apps.matchmaking.models.ddo import MatchmakingTicketDDO
from apps.matchmaking.exceptions.exceptions import TicketNotFoundException
from apps.common.exceptions.exceptions import DatabaseException


# States considered "active" — a user with a ticket in any of these is
# currently committed to a matchmaking attempt and should not be able to
# queue again.
ACTIVE_STATES = ("waiting", "proposed", "accepted")


class _GroupTakenError(Exception):
    """Internal: a concurrent matcher already grabbed part of the group —
    used to roll back propose_group_atomic without surfacing an error."""


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
        mode=row["mode"],
        status=row["status"],
        matched_game_id=row["matched_game_id"],
        created_at=row["created_at"],
        proposed_at=row["proposed_at"],
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
                        message=f"No encontramos la búsqueda {ticket_id}"
                    )
                return _row_to_ddo(result)
            except TicketNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    async def list_waiting_for_sport(
        self, sport_id: int, mode: str
    ) -> list[MatchmakingTicketDDO]:
        """Waiting tickets for a given (sport, mode) pool. The matcher groups
        per-pool so casual and competitive queuers never share a group."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE sport_id = $1 AND mode = $2 AND status = 'waiting' "
                "AND window_end > now() "
                "ORDER BY created_at ASC"
            )
            try:
                results = await connection.fetch(query, sport_id, mode)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    async def create_ticket(
        self,
        user_id: int,
        sport_id: int,
        max_radius_km: float,
        origin_lat: float,
        origin_lon: float,
        window_start: datetime,
        window_end: datetime,
        mode: str,
    ) -> MatchmakingTicketDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(user_id, sport_id, max_radius_km, origin_lat, origin_lon, "
                " window_start, window_end, mode, status) "
                "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'waiting') RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, user_id, sport_id, max_radius_km,
                    origin_lat, origin_lon, window_start, window_end, mode,
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    async def propose_group_atomic(
        self,
        ticket_ids: list[int],
        user_ids: list[int],
        name: str,
        sport_id: int,
        max_players: int,
        organizer_id: int,
        mode: str,
        court_id: int | None,
        scheduled_at: datetime | None,
    ) -> int | None:
        """Group finalization in ONE transaction: creates the
        pending-acceptance game, flips every ticket 'waiting' → 'proposed'
        (stamping proposed_at) and links the players' roster. If any ticket
        was already grabbed by a concurrent matcher, everything rolls back
        and None is returned — a crash or race can never leave a half-built
        game, half-flipped tickets or a dangling roster behind.

        Returns the new game id, or None when the group was lost."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    game_row = await connection.fetchrow(
                        "INSERT INTO game "
                        "(name, sport_id, organizer_id, max_players, mode, "
                        " level, court_id, scheduled_at, status) "
                        "VALUES ($1, $2, $3, $4, $5, NULL, $6, $7, "
                        "        'pending_acceptance') RETURNING id",
                        name, sport_id, organizer_id, max_players,
                        mode, court_id, scheduled_at,
                    )
                    game_id = int(game_row["id"])
                    flipped = await connection.fetch(
                        f"UPDATE {self.__table_name__} "
                        "SET status = 'proposed', matched_game_id = $1, "
                        "    proposed_at = now() "
                        "WHERE id = ANY($2::int[]) AND status = 'waiting' "
                        "RETURNING id",
                        game_id, ticket_ids,
                    )
                    if len(flipped) != len(ticket_ids):
                        raise _GroupTakenError()
                    # Users without a player profile are skipped naturally
                    # (same behavior the old per-ticket loop had).
                    await connection.execute(
                        "INSERT INTO game_player (game_id, player_id) "
                        "SELECT $1, p.id FROM player p "
                        "WHERE p.user_id = ANY($2::int[])",
                        game_id, user_ids,
                    )
                    return game_id
            except _GroupTakenError:
                return None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_stale_game_ids(self, timeout_seconds: int) -> list[int]:
        """Distinct matched_game_ids whose acceptance phase timed out.
        A group is stale if any of its proposed-or-accepted tickets is older
        than timeout_seconds since `proposed_at`."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT DISTINCT matched_game_id FROM {self.__table_name__} "
                "WHERE status IN ('proposed', 'accepted') "
                "AND matched_game_id IS NOT NULL "
                "AND proposed_at IS NOT NULL "
                f"AND proposed_at < now() - ($1 || ' seconds')::interval"
            )
            try:
                results = await connection.fetch(query, str(timeout_seconds))
                return [r["matched_game_id"] for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def expire_group(self, matched_game_id: int) -> int:
        """Collapse a timed-out group: tickets that never accepted become
        'expired'; tickets that did accept are returned to the queue."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"UPDATE {self.__table_name__} "
                "SET status = CASE "
                "    WHEN status = 'accepted' THEN 'waiting' "
                "    ELSE 'expired' "
                "END, "
                "matched_game_id = CASE "
                "    WHEN status = 'accepted' THEN NULL "
                "    ELSE matched_game_id "
                "END, "
                "proposed_at = NULL "
                "WHERE matched_game_id = $1 AND status IN ('proposed', 'accepted') "
                "RETURNING id"
            )
            try:
                results = await connection.fetch(query, matched_game_id)
                return len(results)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")
