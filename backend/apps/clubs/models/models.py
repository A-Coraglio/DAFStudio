from apps.clubs.models import GeneralModel
from apps.clubs.models.ddo import ClubDDO
from apps.clubs.exceptions.exceptions import ClubNotFoundException
from apps.common.exceptions.exceptions import DatabaseException
from typing import cast
from asyncpg.pool import PoolConnectionProxy


def _row_to_ddo(row) -> ClubDDO:
    return ClubDDO(
        id=row["id"],
        owner_id=row["owner_id"],
        name=row["name"],
        address=row["address"],
        city=row["city"],
        description=row["description"],
    )


class ClubModel(GeneralModel):
    __table_name__ = "club"

    async def list_clubs(self, city: str | None = None) -> list[ClubDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            where = ""
            params: list = []
            if city is not None:
                where = "WHERE lower(city) = lower($1)"
                params.append(city)

            query = f"SELECT * FROM {self.__table_name__} {where} ORDER BY name"
            try:
                results = await connection.fetch(query, *params)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_club_by_id(self, club_id: int) -> ClubDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, club_id)
                if result is None:
                    raise ClubNotFoundException(
                        message=f"No encontramos el club {club_id}"
                    )
                return _row_to_ddo(result)
            except ClubNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create_club(
        self,
        owner_id: int,
        name: str,
        address: str,
        city: str,
        description: str | None,
    ) -> ClubDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(owner_id, name, address, city, description) "
                "VALUES ($1, $2, $3, $4, $5) RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, owner_id, name, address, city, description
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def update_club(
        self,
        club_id: int,
        name: str | None = None,
        address: str | None = None,
        city: str | None = None,
        description: str | None = None,
    ) -> ClubDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            fields: list[str] = []
            values: list = []
            idx = 1
            if name is not None:
                fields.append(f"name = ${idx}"); values.append(name); idx += 1
            if address is not None:
                fields.append(f"address = ${idx}"); values.append(address); idx += 1
            if city is not None:
                fields.append(f"city = ${idx}"); values.append(city); idx += 1
            if description is not None:
                fields.append(f"description = ${idx}"); values.append(description); idx += 1

            if not fields:
                return None

            values.append(club_id)
            query = (
                f"UPDATE {self.__table_name__} SET {', '.join(fields)} "
                f"WHERE id = ${idx} RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, *values)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def delete_club(self, club_id: int) -> int | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"DELETE FROM {self.__table_name__} WHERE id = $1 RETURNING id"
            try:
                result = await connection.fetchrow(query, club_id)
                return result["id"] if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
