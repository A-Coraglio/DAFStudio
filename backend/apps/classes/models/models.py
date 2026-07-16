from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.classes.models import GeneralModel
from apps.classes.models.ddo import ClassDDO
from apps.classes.exceptions.exceptions import ClassNotFoundException
from apps.common.exceptions.exceptions import DatabaseException


def _row_to_ddo(row) -> ClassDDO:
    first = row.get("first_name")
    last = row.get("last_name")
    name = " ".join(p for p in (first, last) if p).strip()
    display_name = name if name else row["username"]
    sport_ids = row.get("sport_ids")
    return ClassDDO(
        id=row["id"],
        user_id=row["user_id"],
        display_name=display_name,
        bio=row["bio"],
        price_per_hour=row["price_per_hour"],
        experience_years=row["experience_years"],
        sport_ids=list(sport_ids) if sport_ids is not None else [],
        lat=row["lat"],
        lon=row["lon"],
        distance_km=row.get("distance_km"),
    )


def _haversine_sql(lat_param: int, lon_param: int) -> str:
    """Distance in km from the teacher's home (u.home_lat, u.home_lon) to the
    point at (${lat_param}, ${lon_param})."""
    return (
        f"(2 * 6371 * asin(sqrt("
        f"power(sin(radians(u.home_lat - ${lat_param}) / 2), 2) + "
        f"cos(radians(${lat_param})) * cos(radians(u.home_lat)) * "
        f"power(sin(radians(u.home_lon - ${lon_param}) / 2), 2)"
        f")))"
    )


class ClassModel(GeneralModel):
    __table_name__ = "teacher"

    _BASE_SELECT = (
        "SELECT t.id, t.user_id, t.bio, t.price_per_hour, t.experience_years, "
        "u.username, u.home_lat AS lat, u.home_lon AS lon, "
        "p.first_name, p.last_name, "
        "COALESCE(array_agg(ts.sport_id) FILTER (WHERE ts.sport_id IS NOT NULL), "
        "ARRAY[]::int[]) AS sport_ids"
    )
    _BASE_FROM = (
        "FROM teacher t "
        "JOIN auth_user u ON u.id = t.user_id "
        "LEFT JOIN player p ON p.user_id = t.user_id "
        "LEFT JOIN teacher_sport ts ON ts.teacher_id = t.id"
    )
    _GROUP_BY = (
        "GROUP BY t.id, t.user_id, t.bio, t.price_per_hour, t.experience_years, "
        "u.username, u.home_lat, u.home_lon, p.first_name, p.last_name"
    )

    async def list_classes(
        self,
        sport_id: int | None = None,
        max_price: float | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> list[ClassDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            where: list[str] = []
            params: list = []
            idx = 1

            if sport_id is not None:
                where.append(
                    "EXISTS (SELECT 1 FROM teacher_sport tsf "
                    f"WHERE tsf.teacher_id = t.id AND tsf.sport_id = ${idx})"
                )
                params.append(sport_id); idx += 1
            if max_price is not None:
                where.append(f"t.price_per_hour <= ${idx}")
                params.append(max_price); idx += 1

            select_distance = ", NULL::float AS distance_km"
            order_clause = "ORDER BY t.price_per_hour ASC"
            if near_lat is not None and near_lon is not None:
                dist = _haversine_sql(idx, idx + 1)
                params.extend([near_lat, near_lon]); idx += 2
                select_distance = f", {dist} AS distance_km"
                order_clause = (
                    "ORDER BY (u.home_lat IS NOT NULL AND u.home_lon IS NOT NULL) "
                    f"DESC, {dist} ASC NULLS LAST, t.price_per_hour ASC"
                )
                if radius_km is not None:
                    where.append(
                        "u.home_lat IS NOT NULL AND u.home_lon IS NOT NULL AND "
                        f"{dist} <= ${idx}"
                    )
                    params.append(radius_km); idx += 1

            where_sql = f"WHERE {' AND '.join(where)}" if where else ""
            params.extend([limit, offset])
            query = (
                f"{self._BASE_SELECT}{select_distance} {self._BASE_FROM} "
                f"{where_sql} {self._GROUP_BY} {order_clause} "
                f"LIMIT ${idx} OFFSET ${idx + 1}"
            )
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def recommend_classes(
        self,
        favorite_sport_id: int | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        limit: int = 8,
        sport_id: int | None = None,
    ) -> list[ClassDDO]:
        """Carousel feed: all teachers, softly ranked by whether they teach the
        user's favorite sport and by proximity. [sport_id] is a HARD filter:
        when the client pins a sport (home selector) only teachers of that
        sport come back."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            params: list = []
            idx = 1
            order_parts: list[str] = []
            where: list[str] = []
            select_distance = ", NULL::float AS distance_km"

            if sport_id is not None:
                where.append(
                    "EXISTS (SELECT 1 FROM teacher_sport tsf "
                    f"WHERE tsf.teacher_id = t.id AND tsf.sport_id = ${idx})"
                )
                params.append(sport_id); idx += 1
            if favorite_sport_id is not None:
                order_parts.append(
                    "(EXISTS (SELECT 1 FROM teacher_sport tsr "
                    f"WHERE tsr.teacher_id = t.id AND tsr.sport_id = ${idx})) DESC"
                )
                params.append(favorite_sport_id); idx += 1
            if near_lat is not None and near_lon is not None:
                dist = _haversine_sql(idx, idx + 1)
                params.extend([near_lat, near_lon]); idx += 2
                select_distance = f", {dist} AS distance_km"
                order_parts.append(f"{dist} ASC NULLS LAST")
            order_parts.append("t.price_per_hour ASC")

            where_sql = f"WHERE {' AND '.join(where)}" if where else ""
            params.append(limit)
            query = (
                f"{self._BASE_SELECT}{select_distance} {self._BASE_FROM} "
                f"{where_sql} {self._GROUP_BY} "
                f"ORDER BY {', '.join(order_parts)} LIMIT ${idx}"
            )
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_class_by_id(self, teacher_id: int) -> ClassDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"{self._BASE_SELECT}, NULL::float AS distance_km {self._BASE_FROM} "
                f"WHERE t.id = $1 {self._GROUP_BY}"
            )
            try:
                result = await connection.fetchrow(query, teacher_id)
                if result is None:
                    raise ClassNotFoundException(
                        message=f"Teacher with id {teacher_id} not found"
                    )
                return _row_to_ddo(result)
            except ClassNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
