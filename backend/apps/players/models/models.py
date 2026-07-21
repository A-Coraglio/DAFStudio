from apps.players.models import GeneralModel
from apps.players.models.ddo import PlayerDDO
from apps.players.exceptions.exceptions import PlayerNotFoundException
from apps.common.exceptions.exceptions import DatabaseException
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
                        message=f"No encontramos el jugador {player_id}"
                    )
                return _row_to_ddo(result)
            except PlayerNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_player_by_user_id(self, user_id: int) -> PlayerDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE user_id = $1"
            try:
                result = await connection.fetchrow(query, user_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    async def search_players(
        self,
        query: str | None = None,
        sport_id: int | None = None,
        level: str | None = None,
        exclude_user_id: int | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> list[PlayerDDO]:
        """Discovery feed: list players matching optional filters, ordered by
        ranking so "interesting" players surface first. `query` matches a
        case-insensitive substring against first_name OR last_name.

        Ranking source is player_sport_stat (the real ELO): the sport filter
        when given, the player's favorite sport otherwise, 1000 default —
        never the legacy 0-based player.ranking_points."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            where_clauses: list[str] = []
            params: list = []
            idx = 1

            # LEFT JOIN against the ranking sport: $1 (sport filter, nullable)
            # falls back to the player's own favorite sport.
            join_sql = (
                "LEFT JOIN player_sport_stat pss ON pss.player_id = p.id "
                f"AND pss.sport_id = COALESCE(${idx}::int, p.favorite_sport_id)"
            )
            params.append(sport_id); idx += 1

            if query is not None and query.strip():
                where_clauses.append(
                    f"(p.first_name ILIKE ${idx} OR p.last_name ILIKE ${idx})"
                )
                params.append(f"%{query.strip()}%"); idx += 1
            if sport_id is not None:
                where_clauses.append(f"p.favorite_sport_id = ${idx}")
                params.append(sport_id); idx += 1
            if level is not None:
                where_clauses.append(f"p.level = ${idx}")
                params.append(level); idx += 1
            if exclude_user_id is not None:
                where_clauses.append(f"p.user_id <> ${idx}")
                params.append(exclude_user_id); idx += 1

            where_sql = (
                f"WHERE {' AND '.join(where_clauses)}" if where_clauses else ""
            )
            # ORDER ranking DESC, then by id so the order is stable across
            # pages when many players share the 1000 bootstrap.
            params.extend([limit, offset])
            query_sql = (
                "SELECT p.*, COALESCE(pss.ranking_points, 1000) AS sport_ranking "
                f"FROM {self.__table_name__} p {join_sql} {where_sql} "
                f"ORDER BY sport_ranking DESC, p.id ASC "
                f"LIMIT ${idx} OFFSET ${idx + 1}"
            )
            try:
                results = await connection.fetch(query_sql, *params)
                ddos = []
                for r in results:
                    ddo = _row_to_ddo(r)
                    ddo.ranking_points = r["sport_ranking"]
                    ddos.append(ddo)
                return ddos
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

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
                raise DatabaseException(message=f"Database error: {e}")

    # --- Per-sport ranking (player_sport_stat) -----------------------------

    async def get_sport_ranking(self, player_id: int, sport_id: int) -> int:
        """Ranking of a player in one sport. A (player, sport) pair that has
        never played ranked in that sport defaults to the 1000 base."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                value = await connection.fetchval(
                    "SELECT ranking_points FROM player_sport_stat "
                    "WHERE player_id = $1 AND sport_id = $2",
                    player_id, sport_id,
                )
                return value if value is not None else 1000
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_sport_rankings(
        self, sport_id: int, player_ids: list[int]
    ) -> dict[int, int]:
        """Batch {player_id: ranking} for one sport. Missing rows default to
        1000 so callers can index every requested player."""
        result = {pid: 1000 for pid in player_ids}
        if not player_ids:
            return result
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                rows = await connection.fetch(
                    "SELECT player_id, ranking_points FROM player_sport_stat "
                    "WHERE sport_id = $1 AND player_id = ANY($2::int[])",
                    sport_id, player_ids,
                )
                for r in rows:
                    result[r["player_id"]] = r["ranking_points"]
                return result
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def adjust_rankings(
        self, player_id: int, sport_id: int, delta: int
    ) -> None:
        """ELO application for one player: the per-sport ranking (source of
        truth) and the denormalised overall move in one transaction, so a
        failure between the two can't leave them out of sync."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    await connection.execute(
                        "INSERT INTO player_sport_stat "
                        "(player_id, sport_id, ranking_points) VALUES ($1, $2, 1000 + $3) "
                        "ON CONFLICT (player_id, sport_id) DO UPDATE "
                        "SET ranking_points = player_sport_stat.ranking_points + $3",
                        player_id, sport_id, delta,
                    )
                    await connection.execute(
                        f"UPDATE {self.__table_name__} "
                        "SET ranking_points = ranking_points + $1 WHERE id = $2",
                        delta, player_id,
                    )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
