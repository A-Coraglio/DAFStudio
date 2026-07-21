from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.sport_modes.models import GeneralModel
from apps.sport_modes.models.ddo import SportModeDDO
from apps.sport_modes.exceptions.exceptions import SportModeNotFoundException
from apps.common.exceptions.exceptions import DatabaseException


def _row_to_ddo(row) -> SportModeDDO:
    return SportModeDDO(
        id=row["id"],
        sport_id=row["sport_id"],
        name=row["name"],
        max_players_per_team=row["max_players_per_team"],
    )


class SportModeModel(GeneralModel):
    __table_name__ = "sport_mode"

    async def list_all(self) -> list[SportModeDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} ORDER BY sport_id, name"
            try:
                results = await connection.fetch(query)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_for_sport(self, sport_id: int) -> list[SportModeDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE sport_id = $1 ORDER BY name"
            )
            try:
                results = await connection.fetch(query, sport_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_by_id(self, mode_id: int) -> SportModeDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, mode_id)
                if result is None:
                    raise SportModeNotFoundException(
                        message=f"No encontramos el modo de juego {mode_id}"
                    )
                return _row_to_ddo(result)
            except SportModeNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create(
        self, sport_id: int, name: str, max_players_per_team: int
    ) -> SportModeDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(sport_id, name, max_players_per_team) "
                "VALUES ($1, $2, $3) RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, sport_id, name, max_players_per_team
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
