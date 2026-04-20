from apps.players.models import GeneralModel
from apps.players.models.ddo import PlayerDDO
from apps.players.exceptions.exceptions import PlayerNotFoundException
from apps.games.exceptions.exceptions import DatbaseException
from typing import cast
from asyncpg.pool import PoolConnectionProxy


def _row_to_ddo(row) -> PlayerDDO:
    return PlayerDDO(
        id=row["id"],
        user_id=row["user_id"],
        first_name=row["first_name"],
        last_name=row["last_name"],
        level=row["level"],
        ranking_points=row["ranking_points"],
        favorite_sport_id=row["favorite_sport_id"],
        avatar_path=row["avatar_path"],
    )


class PlayerModel(GeneralModel):
    __table_name__ = "player"

    async def get_player_by_id(self, player_id: int) -> PlayerDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                result = await connection.fetchrow(query, player_id)
                if result is None:
                    raise PlayerNotFoundException(
                        message=f"Player with id {player_id} not found"
                    )
                return _row_to_ddo(result)
            except PlayerNotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def get_player_by_user_id(self, user_id: int) -> PlayerDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE user_id = $1"
            try:
                result = await connection.fetchrow(query, user_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def list_players_by_user_ids(
        self, user_ids: list[int]
    ) -> list[PlayerDDO]:
        if not user_ids:
            return []
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE user_id = ANY($1::int[])"
            )
            try:
                results = await connection.fetch(query, user_ids)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def list_players_by_ids(
        self, player_ids: list[int]
    ) -> list[PlayerDDO]:
        if not player_ids:
            return []
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE id = ANY($1::int[])"
            )
            try:
                results = await connection.fetch(query, player_ids)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create_player(
        self,
        user_id: int,
        first_name: str | None = None,
        last_name: str | None = None,
        level: str | None = None,
        favorite_sport_id: int | None = None,
    ) -> PlayerDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(user_id, first_name, last_name, level, ranking_points, favorite_sport_id) "
                "VALUES ($1, $2, $3, $4, 0, $5) RETURNING *"
            )
            try:
                result = await connection.fetchrow(
                    query, user_id, first_name, last_name, level, favorite_sport_id
                )
                return _row_to_ddo(result)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def update_player(
        self,
        player_id: int,
        first_name: str | None = None,
        last_name: str | None = None,
        level: str | None = None,
        favorite_sport_id: int | None = None,
    ) -> PlayerDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            fields: list[str] = []
            values: list = []
            idx = 1
            if first_name is not None:
                fields.append(f"first_name = ${idx}"); values.append(first_name); idx += 1
            if last_name is not None:
                fields.append(f"last_name = ${idx}"); values.append(last_name); idx += 1
            if level is not None:
                fields.append(f"level = ${idx}"); values.append(level); idx += 1
            if favorite_sport_id is not None:
                fields.append(f"favorite_sport_id = ${idx}"); values.append(favorite_sport_id); idx += 1

            if not fields:
                return None

            values.append(player_id)
            query = (
                f"UPDATE {self.__table_name__} SET {', '.join(fields)} "
                f"WHERE id = ${idx} RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, *values)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def set_avatar_path(
        self, player_id: int, avatar_path: str | None
    ) -> PlayerDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"UPDATE {self.__table_name__} "
                "SET avatar_path = $1 WHERE id = $2 RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, avatar_path, player_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def adjust_ranking_points(
        self, player_id: int, delta: int
    ) -> PlayerDDO | None:
        """Used by the result-finalization flow to apply ELO deltas."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"UPDATE {self.__table_name__} "
                "SET ranking_points = ranking_points + $1 "
                "WHERE id = $2 RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, delta, player_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
