from apps.courts.models import GeneralModel
from apps.courts.models.ddo import CourtDDO
from apps.courts.exceptions.exceptions import CourtNotFoundException
from apps.games.exceptions.exceptions import DatbaseException
from typing import cast
from asyncpg.pool import PoolConnectionProxy


def _row_to_ddo(row) -> CourtDDO:
    return CourtDDO(
        id=row["id"],
        club_id=row["club_id"],
        owner_id=row["owner_id"],
        sport_id=row["sport_id"],
        name=row["name"],
        price_per_hour=row["price_per_hour"],
        is_indoor=row["is_indoor"],
        lat=row["lat"],
        lon=row["lon"],
    )


def _haversine_sql(lat_param: int, lon_param: int) -> str:
    """Builds a Postgres expression that returns distance in km from the row's
    (lat, lon) to the parameter point ($lat_param, $lon_param)."""
    return (
        f"(2 * 6371 * asin(sqrt("
        f"power(sin(radians(lat - ${lat_param}) / 2), 2) + "
        f"cos(radians(${lat_param})) * cos(radians(lat)) * "
        f"power(sin(radians(lon - ${lon_param}) / 2), 2)"
        f")))"
    )


class CourtModel(GeneralModel):
    __table_name__ = "court"

    async def list_courts(
        self,
        current_user_id: int,
        sport_id: int | None = None,
        club_id: int | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
    ) -> list[CourtDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            # Visibility: public club courts OR user's own private courts.
            where_clauses = ["(club_id IS NOT NULL OR owner_id = $1)"]
            params: list = [current_user_id]
            idx = 2

            if sport_id is not None:
                where_clauses.append(f"sport_id = ${idx}")
                params.append(sport_id)
                idx += 1

            if club_id is not None:
                where_clauses.append(f"club_id = ${idx}")
                params.append(club_id)
                idx += 1

            order_clause = "ORDER BY name"
            if near_lat is not None and near_lon is not None and radius_km is not None:
                distance_expr = _haversine_sql(idx, idx + 1)
                where_clauses.append(
                    f"lat IS NOT NULL AND lon IS NOT NULL AND {distance_expr} <= ${idx + 2}"
                )
                order_clause = f"ORDER BY {distance_expr}"
                params.extend([near_lat, near_lon, radius_km])
                idx += 3

            query = (
                f"SELECT * FROM {self.__table_name__} "
                f"WHERE {' AND '.join(where_clauses)} "
                f"{order_clause}"
            )

            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def get_court_by_id(
        self, court_id: int, current_user_id: int
    ) -> CourtDDO:
        """Returns the court only if visible to current_user (public club
        court, or private court they own). Otherwise raises NotFound — we
        don't leak existence of other users' private courts."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                f"WHERE id = $1 AND (club_id IS NOT NULL OR owner_id = $2)"
            )
            try:
                result = await connection.fetchrow(query, court_id, current_user_id)
                if result is None:
                    raise CourtNotFoundException(
                        message=f"Court with id {court_id} not found"
                    )
                return _row_to_ddo(result)
            except CourtNotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def get_court_raw(self, court_id: int) -> CourtDDO | None:
        """Reads a court bypassing visibility rules — used internally when the
        service needs to check ownership before enforcing 403 vs 404."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, court_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create_private_court(
        self,
        name: str,
        sport_id: int,
        owner_id: int,
        price_per_hour: float,
        is_indoor: bool,
        lat: float | None,
        lon: float | None,
    ) -> CourtDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(name, sport_id, owner_id, price_per_hour, is_indoor, lat, lon) "
                "VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, name, sport_id, owner_id, price_per_hour, is_indoor, lat, lon
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create_club_court(
        self,
        name: str,
        sport_id: int,
        club_id: int,
        price_per_hour: float,
        is_indoor: bool,
        lat: float | None,
        lon: float | None,
    ) -> CourtDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(name, sport_id, club_id, price_per_hour, is_indoor, lat, lon) "
                "VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, name, sport_id, club_id, price_per_hour, is_indoor, lat, lon
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def update_private_court(
        self,
        court_id: int,
        name: str | None = None,
        sport_id: int | None = None,
        price_per_hour: float | None = None,
        is_indoor: bool | None = None,
        lat: float | None = None,
        lon: float | None = None,
    ) -> CourtDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            fields: list[str] = []
            values: list = []
            idx = 1
            if name is not None:
                fields.append(f"name = ${idx}"); values.append(name); idx += 1
            if sport_id is not None:
                fields.append(f"sport_id = ${idx}"); values.append(sport_id); idx += 1
            if price_per_hour is not None:
                fields.append(f"price_per_hour = ${idx}"); values.append(price_per_hour); idx += 1
            if is_indoor is not None:
                fields.append(f"is_indoor = ${idx}"); values.append(is_indoor); idx += 1
            if lat is not None:
                fields.append(f"lat = ${idx}"); values.append(lat); idx += 1
            if lon is not None:
                fields.append(f"lon = ${idx}"); values.append(lon); idx += 1

            if not fields:
                return None

            values.append(court_id)
            query = (
                f"UPDATE {self.__table_name__} SET {', '.join(fields)} "
                f"WHERE id = ${idx} RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, *values)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def delete_court(self, court_id: int) -> int | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"DELETE FROM {self.__table_name__} WHERE id = $1 RETURNING id"
            try:
                result = await connection.fetchrow(query, court_id)
                return result["id"] if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
