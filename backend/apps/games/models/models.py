from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.games.models import GeneralModel
from apps.games.models.ddo import GameDDO
from apps.common.exceptions.exceptions import DatabaseException, NotFoundException


def _row_to_ddo(row) -> GameDDO:
    return GameDDO(
        id=row["id"],
        name=row["name"],
        sport_id=row["sport_id"],
        organizer_id=row["organizer_id"],
        court_id=row["court_id"],
        max_players=row["max_players"],
        level=row["level"],
        mode=row["mode"],
        status=row["status"],
        scheduled_at=row["scheduled_at"],
        result_home=row["result_home"],
        result_away=row["result_away"],
        created_at=row["created_at"],
        # Present only on queries that JOIN sports; .get() keeps the
        # INSERT/UPDATE ... RETURNING * callers working unchanged.
        sport_name=row.get("sport_name"),
        # Present only when list_games is called with a near point.
        distance_km=row.get("distance_km"),
    )


def _haversine_sql(court_alias: str, lat_param: int, lon_param: int) -> str:
    """Distance in km from (court_alias.lat, court_alias.lon) to
    the parameter point ($lat_param, $lon_param)."""
    return (
        f"(2 * 6371 * asin(sqrt("
        f"power(sin(radians({court_alias}.lat - ${lat_param}) / 2), 2) + "
        f"cos(radians(${lat_param})) * cos(radians({court_alias}.lat)) * "
        f"power(sin(radians({court_alias}.lon - ${lon_param}) / 2), 2)"
        f")))"
    )


class GamesModel(GeneralModel):
    __table_name__ = "game"

    async def list_games(
        self,
        sport_id: int | None = None,
        mode: str | None = None,
        level: str | None = None,
        status: str | None = None,
        organizer_id: int | None = None,
        scheduled_after: datetime | None = None,
        scheduled_before: datetime | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
    ) -> list[GameDDO]:
        """Lists games with optional filters. Geo filtering joins against the
        court table and excludes games without a resolved court."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            where_clauses: list[str] = []
            params: list = []
            idx = 1

            if sport_id is not None:
                where_clauses.append(f"g.sport_id = ${idx}")
                params.append(sport_id); idx += 1
            if mode is not None:
                where_clauses.append(f"g.mode = ${idx}")
                params.append(mode); idx += 1
            if level is not None:
                where_clauses.append(f"g.level = ${idx}")
                params.append(level); idx += 1
            if status is not None:
                where_clauses.append(f"g.status = ${idx}")
                params.append(status); idx += 1
            if organizer_id is not None:
                where_clauses.append(f"g.organizer_id = ${idx}")
                params.append(organizer_id); idx += 1
            if scheduled_after is not None:
                where_clauses.append(f"g.scheduled_at >= ${idx}")
                params.append(scheduled_after); idx += 1
            if scheduled_before is not None:
                where_clauses.append(f"g.scheduled_at <= ${idx}")
                params.append(scheduled_before); idx += 1

            order_clause = "ORDER BY COALESCE(g.scheduled_at, g.created_at)"
            select_distance = ""

            # With a near point, expose `distance_km` to each game's court and
            # order by it. A radius (when given) additionally filters anything
            # beyond it; without a radius nothing is filtered — the feed still
            # shows courtless games (null distance, sorted last).
            if near_lat is not None and near_lon is not None:
                distance_expr = _haversine_sql("c", idx, idx + 1)
                params.extend([near_lat, near_lon])
                idx += 2
                select_distance = f", {distance_expr} AS distance_km"
                order_clause = "ORDER BY distance_km ASC NULLS LAST"
                if radius_km is not None:
                    where_clauses.append(
                        f"c.lat IS NOT NULL AND c.lon IS NOT NULL "
                        f"AND {distance_expr} <= ${idx}"
                    )
                    params.append(radius_km)
                    idx += 1

            where_sql = f"WHERE {' AND '.join(where_clauses)}" if where_clauses else ""
            query = (
                f"SELECT g.*, s.name AS sport_name{select_distance} "
                f"FROM {self.__table_name__} g "
                f"LEFT JOIN court c ON c.id = g.court_id "
                f"LEFT JOIN sports s ON s.id = g.sport_id "
                f"{where_sql} {order_clause}"
            )
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_game_by_id(self, game_id: int) -> GameDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT g.*, s.name AS sport_name FROM {self.__table_name__} g "
                f"LEFT JOIN sports s ON s.id = g.sport_id "
                f"WHERE g.id = $1"
            )
            try:
                result = await connection.fetchrow(query, game_id)
                if result is None:
                    raise NotFoundException(
                        message=f"Game with id {game_id} not found"
                    )
                return _row_to_ddo(result)
            except NotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create_game(
        self,
        name: str,
        sport_id: int,
        max_players: int,
        organizer_id: int,
        mode: str,
        level: str | None = None,
        court_id: int | None = None,
        scheduled_at: datetime | None = None,
    ) -> GameDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(name, sport_id, organizer_id, max_players, mode, level, court_id, scheduled_at, status) "
                "VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'open') RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, name, sport_id, organizer_id, max_players,
                    mode, level, court_id, scheduled_at,
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def update_game(
        self,
        game_id: int,
        name: str | None = None,
        max_players: int | None = None,
        court_id: int | None = None,
        level: str | None = None,
        scheduled_at: datetime | None = None,
        status: str | None = None,
    ) -> GameDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            fields: list[str] = []
            values: list = []
            idx = 1
            if name is not None:
                fields.append(f"name = ${idx}"); values.append(name); idx += 1
            if max_players is not None:
                fields.append(f"max_players = ${idx}"); values.append(max_players); idx += 1
            if court_id is not None:
                fields.append(f"court_id = ${idx}"); values.append(court_id); idx += 1
            if level is not None:
                fields.append(f"level = ${idx}"); values.append(level); idx += 1
            if scheduled_at is not None:
                fields.append(f"scheduled_at = ${idx}"); values.append(scheduled_at); idx += 1
            if status is not None:
                fields.append(f"status = ${idx}"); values.append(status); idx += 1

            if not fields:
                return None

            values.append(game_id)
            query = (
                f"UPDATE {self.__table_name__} SET {', '.join(fields)} "
                f"WHERE id = ${idx} RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, *values)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_games_for_player(
        self,
        player_id: int,
        status: str | None = None,
        mode: str | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> list[GameDDO]:
        """All games a player participated in (via game_player). Newest first
        by scheduled_at then created_at so future/recent games surface first."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            where_clauses = ["gp.player_id = $1"]
            params: list = [player_id]
            idx = 2
            if status is not None:
                where_clauses.append(f"g.status = ${idx}")
                params.append(status); idx += 1
            if mode is not None:
                where_clauses.append(f"g.mode = ${idx}")
                params.append(mode); idx += 1

            params.extend([limit, offset])
            query = (
                f"SELECT g.*, s.name AS sport_name "
                f"FROM {self.__table_name__} g "
                f"INNER JOIN game_player gp ON gp.game_id = g.id "
                f"LEFT JOIN sports s ON s.id = g.sport_id "
                f"WHERE {' AND '.join(where_clauses)} "
                f"ORDER BY COALESCE(g.scheduled_at, g.created_at) DESC "
                f"LIMIT ${idx} OFFSET ${idx + 1}"
            )
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_pending_settlement(
        self, grace_hours: int
    ) -> list[GameDDO]:
        """Games whose `scheduled_at` is more than `grace_hours` in the past
        and that are still in a reportable state (open / full). These are the
        candidates for the auto-settle job: either everyone forgot to report,
        or some reported and consensus stalled."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT g.*, s.name AS sport_name FROM {self.__table_name__} g "
                f"LEFT JOIN sports s ON s.id = g.sport_id "
                f"WHERE g.status IN ('open', 'full') "
                f"AND g.scheduled_at IS NOT NULL "
                f"AND g.scheduled_at < (now() - ($1 || ' hours')::interval)"
            )
            try:
                results = await connection.fetch(query, str(grace_hours))
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def set_result(
        self,
        game_id: int,
        result_home: int,
        result_away: int,
    ) -> GameDDO | None:
        """Atomically sets the final score and marks the game as finished."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"UPDATE {self.__table_name__} "
                "SET result_home = $1, result_away = $2, status = 'finished' "
                "WHERE id = $3 RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, result_home, result_away, game_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def finish_without_result(self, game_id: int) -> GameDDO | None:
        """Closes a game as 'finished' without a score. Used when the
        auto-settle job runs and either nobody reported or the votes had no
        clear majority. ELO is not applied for these games."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"UPDATE {self.__table_name__} "
                "SET status = 'finished' "
                "WHERE id = $1 RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, game_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def delete_game(self, game_id: int) -> int:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"DELETE FROM {self.__table_name__} WHERE id = $1 RETURNING id"
            try:
                result = await connection.fetchrow(query, game_id)
                if result is None:
                    raise NotFoundException(
                        message=f"Game with id {game_id} not found"
                    )
                return result["id"]
            except NotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
