from apps.users.models.ddo import UserDDO
from apps.users.models import GeneralModel
from typing import cast
from asyncpg.pool import PoolConnectionProxy

from apps.common.exceptions.exceptions import DatabaseException


def _row_to_ddo(row) -> UserDDO:
    return UserDDO(
        id=row["id"],
        username=row["username"],
        email=row["email"],
        password_hash=row["password_hash"],
        # .get() keeps this working if the column is missing (pre-migration).
        has_password=bool(row.get("has_password", True)),
        home_lat=row.get("home_lat"),
        home_lon=row.get("home_lon"),
        created_at=row["created_at"],
    )


class UserModel(GeneralModel):
    __table_name__ = "auth_user"

    async def get_user_by_email(self, email: str) -> UserDDO | None:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = (
                f"SELECT * from {self.__table_name__} "
                "WHERE email = $1 AND deleted_at IS NULL"
            )
            try:
                result = await connection.fetchrow(query, email)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_user_by_email_or_username(
        self, identifier: str
    ) -> UserDDO | None:
        """Login lookup: the identifier can be either the email or the
        username (both are unique)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE (email = $1 OR username = $1) AND deleted_at IS NULL"
            )
            try:
                result = await connection.fetchrow(query, identifier)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_user_by_id(self, user_id: int) -> UserDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT * FROM {self.__table_name__} "
                "WHERE id = $1 AND deleted_at IS NULL"
            )
            try:
                result = await connection.fetchrow(query, user_id)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_existing_ids(self, user_ids: list[int]) -> set[int]:
        """Which of these ids exist in auth_user — one query, used to validate
        references (e.g. chat participants) before hitting FK constraints."""
        if not user_ids:
            return set()
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT id FROM {self.__table_name__} "
                "WHERE id = ANY($1::int[])"
            )
            try:
                rows = await connection.fetch(query, user_ids)
                return {int(r["id"]) for r in rows}
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create_user(self, username: str, email: str, password_hash: str) -> UserDDO:
        async with self.get_db_connection() as connection:
            connection : PoolConnectionProxy = cast(PoolConnectionProxy,connection)
            query = (
                f"INSERT INTO {self.__table_name__} "
                "(username, email, password_hash) VALUES ($1, $2, $3) RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, username, email, password_hash)
                return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create_user_with_player(
        self, username: str, email: str, password_hash: str,
        has_password: bool = True,
    ) -> UserDDO:
        """Registration inserts the auth_user AND its empty player profile in
        one transaction — a failure halfway can't leave an auth_user without
        player (which breaks every player-scoped endpoint for that account).
        `has_password=False` marks Google-provisioned accounts (random hash)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    result = await connection.fetchrow(
                        f"INSERT INTO {self.__table_name__} "
                        "(username, email, password_hash, has_password) "
                        "VALUES ($1, $2, $3, $4) RETURNING *",
                        username, email, password_hash, has_password,
                    )
                    await connection.execute(
                        "INSERT INTO player (user_id) VALUES ($1)",
                        result["id"],
                    )
                    return _row_to_ddo(result)
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def update_user(
        self,
        user_id: int,
        username: str | None = None,
        email: str | None = None,
        password_hash: str | None = None,
        home_lat: float | None = None,
        home_lon: float | None = None,
    ) -> UserDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)

            fields = []
            values = []
            idx = 1
            if username is not None:
                fields.append(f"username = ${idx}")
                values.append(username)
                idx += 1
            if email is not None:
                fields.append(f"email = ${idx}")
                values.append(email)
                idx += 1
            if password_hash is not None:
                fields.append(f"password_hash = ${idx}")
                values.append(password_hash)
                idx += 1
                # Setting any password makes it a "real" one from now on —
                # future changes will require knowing it.
                fields.append("has_password = TRUE")
            # Home moves as a pair — the service validates both-or-neither.
            if home_lat is not None and home_lon is not None:
                fields.append(f"home_lat = ${idx}")
                values.append(home_lat)
                idx += 1
                fields.append(f"home_lon = ${idx}")
                values.append(home_lon)
                idx += 1

            if not fields:
                return None

            values.append(user_id)
            query = (
                f"UPDATE {self.__table_name__} SET {', '.join(fields)} "
                f"WHERE id = ${idx} RETURNING *"
            )
            try:
                result = await connection.fetchrow(query, *values)
                return _row_to_ddo(result) if result else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def soft_delete_user(
        self, user_id: int, scrambled_password_hash: str
    ) -> int | None:
        """Account deletion = soft-delete + anonymization in one transaction:
        the auth_user row stays (games, messages and other players' histories
        keep their FKs intact) but every personal field is wiped, and the
        rename frees the original email/username for a future registration.
        Active matchmaking tickets are cancelled so no ghost queues remain."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    result = await connection.fetchrow(
                        f"UPDATE {self.__table_name__} SET "
                        "deleted_at = now(), "
                        "username = 'usuario_eliminado_' || id, "
                        "email = 'deleted+' || id || '@dafstudio.invalid', "
                        "password_hash = $2, has_password = FALSE, "
                        "home_lat = NULL, home_lon = NULL "
                        "WHERE id = $1 AND deleted_at IS NULL RETURNING id",
                        user_id, scrambled_password_hash,
                    )
                    if result is None:
                        return None
                    await connection.execute(
                        "UPDATE player SET first_name = NULL, "
                        "last_name = NULL, avatar_path = NULL "
                        "WHERE user_id = $1",
                        user_id,
                    )
                    await connection.execute(
                        "UPDATE matchmaking_ticket SET status = 'cancelled' "
                        "WHERE user_id = $1 "
                        "AND status IN ('waiting', 'proposed', 'accepted')",
                        user_id,
                    )
                    return int(result["id"])
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
