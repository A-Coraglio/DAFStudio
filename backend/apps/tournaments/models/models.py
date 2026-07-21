from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.tournaments.models import GeneralModel
from apps.tournaments.models.ddo import TournamentDDO
from apps.tournaments.exceptions.exceptions import TournamentNotFoundException
from apps.common.exceptions.exceptions import DatabaseException


def _row_to_ddo(row) -> TournamentDDO:
    return TournamentDDO(
        id=row["id"],
        organizer_id=row["organizer_id"],
        sport_id=row["sport_id"],
        club_id=row["club_id"],
        name=row["name"],
        description=row["description"],
        start_date=row["start_date"],
        end_date=row["end_date"],
        max_participants=row["max_participants"],
        status=row["status"],
        level=row["level"],
        lat=row["lat"],
        lon=row["lon"],
        participant_count=row.get("participant_count", 0) or 0,
        distance_km=row.get("distance_km"),
    )


def _haversine_sql(lat_param: int, lon_param: int) -> str:
    """Distance in km from the tournament's (t.lat, t.lon) to the point at
    (${lat_param}, ${lon_param})."""
    return (
        f"(2 * 6371 * asin(sqrt("
        f"power(sin(radians(t.lat - ${lat_param}) / 2), 2) + "
        f"cos(radians(${lat_param})) * cos(radians(t.lat)) * "
        f"power(sin(radians(t.lon - ${lon_param}) / 2), 2)"
        f")))"
    )


class TournamentModel(GeneralModel):
    __table_name__ = "tournament"

    # Every read exposes a live participant count so the UI can show "x/y".
    _BASE_SELECT = (
        "SELECT t.*, "
        "(SELECT count(*) FROM tournament_participant tp "
        "WHERE tp.tournament_id = t.id) AS participant_count"
    )

    async def list_tournaments(
        self,
        sport_id: int | None = None,
        level: str | None = None,
        status: str | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> list[TournamentDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            where: list[str] = []
            params: list = []
            idx = 1

            if sport_id is not None:
                where.append(f"t.sport_id = ${idx}"); params.append(sport_id); idx += 1
            if level is not None:
                where.append(f"t.level = ${idx}"); params.append(level); idx += 1
            if status is not None:
                where.append(f"t.status = ${idx}"); params.append(status); idx += 1

            select_distance = ", NULL::float AS distance_km"
            order_clause = "ORDER BY t.start_date ASC"
            if near_lat is not None and near_lon is not None:
                dist = _haversine_sql(idx, idx + 1)
                params.extend([near_lat, near_lon]); idx += 2
                select_distance = f", {dist} AS distance_km"
                # Located tournaments first, then nearest, then soonest.
                order_clause = (
                    "ORDER BY (t.lat IS NOT NULL AND t.lon IS NOT NULL) DESC, "
                    f"{dist} ASC NULLS LAST, t.start_date ASC"
                )
                if radius_km is not None:
                    where.append(
                        f"t.lat IS NOT NULL AND t.lon IS NOT NULL AND {dist} <= ${idx}"
                    )
                    params.append(radius_km); idx += 1

            where_sql = f"WHERE {' AND '.join(where)}" if where else ""
            params.extend([limit, offset])
            query = (
                f"{self._BASE_SELECT}{select_distance} "
                f"FROM {self.__table_name__} t "
                f"{where_sql} {order_clause} LIMIT ${idx} OFFSET ${idx + 1}"
            )
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def recommend_tournaments(
        self,
        favorite_sport_id: int | None = None,
        level: str | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        limit: int = 8,
        sport_id: int | None = None,
    ) -> list[TournamentDDO]:
        """Carousel feed: only future/ongoing tournaments, softly ranked by the
        user's favorite sport, matching level and proximity — none of them a
        hard filter, so the strip is never empty when data exists. [sport_id]
        is the exception: when the client pins a sport (home selector) only
        that sport's tournaments come back."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            params: list = []
            idx = 1
            order_parts: list[str] = []
            where = "WHERE t.status IN ('upcoming', 'ongoing')"
            select_distance = ", NULL::float AS distance_km"

            if sport_id is not None:
                where += f" AND t.sport_id = ${idx}"
                params.append(sport_id); idx += 1
            if favorite_sport_id is not None:
                order_parts.append(f"(t.sport_id = ${idx}) DESC")
                params.append(favorite_sport_id); idx += 1
            if level is not None:
                order_parts.append(f"(t.level = ${idx} OR t.level IS NULL) DESC")
                params.append(level); idx += 1
            if near_lat is not None and near_lon is not None:
                dist = _haversine_sql(idx, idx + 1)
                params.extend([near_lat, near_lon]); idx += 2
                select_distance = f", {dist} AS distance_km"
                order_parts.append(f"{dist} ASC NULLS LAST")
            order_parts.append("t.start_date ASC")

            params.append(limit)
            query = (
                f"{self._BASE_SELECT}{select_distance} "
                f"FROM {self.__table_name__} t "
                f"{where} "
                f"ORDER BY {', '.join(order_parts)} LIMIT ${idx}"
            )
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_tournament_by_id(self, tournament_id: int) -> TournamentDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"{self._BASE_SELECT}, NULL::float AS distance_km "
                f"FROM {self.__table_name__} t WHERE t.id = $1"
            )
            try:
                result = await connection.fetchrow(query, tournament_id)
                if result is None:
                    raise TournamentNotFoundException(
                        message=f"No encontramos el torneo {tournament_id}"
                    )
                return _row_to_ddo(result)
            except TournamentNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
