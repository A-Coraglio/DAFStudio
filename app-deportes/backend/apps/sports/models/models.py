from apps.sports.models import GeneralModel
from apps.sports.models.ddo import SportDDO
from apps.sports.exceptions.exceptions import SportNotFoundException
from apps.common.exceptions.exceptions import DatabaseException
from typing import cast
from asyncpg.pool import PoolConnectionProxy


def _row_to_ddo(row) -> SportDDO:
    return SportDDO(
        id=row["id"],
        name=row["name"],
        max_players_per_team=row["max_players_per_team"],
    )


class SportModel(GeneralModel):
    __table_name__ = "sports"

    async def list_sports(self) -> list[SportDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} ORDER BY name"
            try:
                results = await connection.fetch(query)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_sport_by_id(self, sport_id: int) -> SportDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, sport_id)
                if result is None:
                    raise SportNotFoundException(
                        message=f"No encontramos el deporte {sport_id}"
                    )
                return _row_to_ddo(result)
            except SportNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
