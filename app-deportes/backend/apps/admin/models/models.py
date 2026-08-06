from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.admin.models import GeneralModel
from apps.admin.models.ddo import AdminUserDDO, AuditEntryDDO
from apps.common.exceptions.exceptions import DatabaseException


def _user_row_to_ddo(row) -> AdminUserDDO:
    name = " ".join(
        p for p in (row["first_name"], row["last_name"]) if p
    ).strip()
    return AdminUserDDO(
        user_id=row["id"],
        username=row["username"],
        email=row["email"],
        display_name=name if name else row["username"],
        is_admin=row["is_admin"],
        banned_at=row["banned_at"],
        deleted_at=row["deleted_at"],
        created_at=row["created_at"],
    )


class AdminModel(GeneralModel):
    __table_name__ = "admin"

    async def is_admin(self, user_id: int) -> bool:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                row = await connection.fetchrow(
                    f"SELECT 1 FROM {self.__table_name__} WHERE user_id = $1",
                    user_id,
                )
                return row is not None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def count_admins(self) -> int:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                return await connection.fetchval(
                    f"SELECT COUNT(*) FROM {self.__table_name__}"
                )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def add_admin(self, user_id: int) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                await connection.execute(
                    f"INSERT INTO {self.__table_name__} (user_id) "
                    "VALUES ($1) ON CONFLICT DO NOTHING",
                    user_id,
                )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def remove_admin(self, user_id: int) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                await connection.execute(
                    f"DELETE FROM {self.__table_name__} WHERE user_id = $1",
                    user_id,
                )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_users(
        self, query: str | None = None, limit: int = 50, offset: int = 0
    ) -> list[AdminUserDDO]:
        """Todas las cuentas (incluidas baneadas y soft-borradas) con nombre
        visible y flags — el buscador del panel."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            params: list = []
            idx = 1
            where = ""
            if query and query.strip():
                where = (
                    f"WHERE (u.username ILIKE ${idx} OR u.email ILIKE ${idx} "
                    f"OR p.first_name ILIKE ${idx} OR p.last_name ILIKE ${idx})"
                )
                params.append(f"%{query.strip()}%"); idx += 1
            params.extend([limit, offset])
            sql = (
                "SELECT u.id, u.username, u.email, u.banned_at, u.deleted_at, "
                "u.created_at, p.first_name, p.last_name, "
                "(a.user_id IS NOT NULL) AS is_admin "
                "FROM auth_user u "
                "LEFT JOIN player p ON p.user_id = u.id "
                f"LEFT JOIN {self.__table_name__} a ON a.user_id = u.id "
                f"{where} ORDER BY u.id LIMIT ${idx} OFFSET ${idx + 1}"
            )
            try:
                rows = await connection.fetch(sql, *params)
                return [_user_row_to_ddo(r) for r in rows]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def set_banned(self, user_id: int, banned: bool) -> bool:
        """Marca/desmarca el ban. True si la cuenta existía (y no está
        soft-borrada)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                row = await connection.fetchrow(
                    "UPDATE auth_user "
                    f"SET banned_at = {'now()' if banned else 'NULL'} "
                    "WHERE id = $1 AND deleted_at IS NULL RETURNING id",
                    user_id,
                )
                return row is not None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")


class AuditModel(GeneralModel):
    __table_name__ = "admin_audit_log"

    async def record(
        self,
        admin_user_id: int,
        action: str,
        target_type: str,
        target_id: int,
        detail: str | None = None,
    ) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                await connection.execute(
                    f"INSERT INTO {self.__table_name__} "
                    "(admin_user_id, action, target_type, target_id, detail) "
                    "VALUES ($1, $2, $3, $4, $5)",
                    admin_user_id, action, target_type, target_id, detail,
                )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_entries(
        self, limit: int = 100, offset: int = 0
    ) -> list[AuditEntryDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                rows = await connection.fetch(
                    f"SELECT l.*, u.username AS admin_username "
                    f"FROM {self.__table_name__} l "
                    "JOIN auth_user u ON u.id = l.admin_user_id "
                    "ORDER BY l.id DESC LIMIT $1 OFFSET $2",
                    limit, offset,
                )
                return [
                    AuditEntryDDO(
                        id=r["id"],
                        admin_user_id=r["admin_user_id"],
                        admin_username=r["admin_username"],
                        action=r["action"],
                        target_type=r["target_type"],
                        target_id=r["target_id"],
                        detail=r["detail"],
                        created_at=r["created_at"],
                    )
                    for r in rows
                ]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
