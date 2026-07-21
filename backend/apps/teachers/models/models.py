from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.teachers.models import GeneralModel
from apps.teachers.models.ddo import MyTeacherDDO, TeacherRequestDDO
from apps.teachers.exceptions.exceptions import (
    TeacherNotFoundException,
    TeacherRequestException,
)
from apps.common.exceptions.exceptions import AppException, DatabaseException


def _csv_to_ids(csv: str) -> list[int]:
    return [int(x) for x in csv.split(",") if x.strip()]


def _request_row_to_ddo(row) -> TeacherRequestDDO:
    name = " ".join(
        p for p in (row.get("first_name"), row.get("last_name")) if p
    ).strip()
    return TeacherRequestDDO(
        id=row["id"],
        user_id=row["user_id"],
        bio=row["bio"],
        price_per_hour=row["price_per_hour"],
        experience_years=row["experience_years"],
        sport_ids=_csv_to_ids(row["sport_ids_csv"]),
        status=row["status"],
        created_at=row["created_at"],
        display_name=(name if name else row.get("username")),
        username=row.get("username"),
    )


class TeacherModel(GeneralModel):
    __table_name__ = "teacher"

    async def get_teacher_by_user_id(self, user_id: int) -> MyTeacherDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                row = await connection.fetchrow(
                    "SELECT t.*, COALESCE(array_agg(ts.sport_id) "
                    "FILTER (WHERE ts.sport_id IS NOT NULL), ARRAY[]::int[]) "
                    "AS sport_ids "
                    f"FROM {self.__table_name__} t "
                    "LEFT JOIN teacher_sport ts ON ts.teacher_id = t.id "
                    "WHERE t.user_id = $1 "
                    "GROUP BY t.id",
                    user_id,
                )
                if row is None:
                    return None
                return MyTeacherDDO(
                    id=row["id"],
                    user_id=row["user_id"],
                    bio=row["bio"],
                    price_per_hour=row["price_per_hour"],
                    experience_years=row["experience_years"],
                    sport_ids=list(row["sport_ids"]),
                )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def update_teacher(
        self,
        teacher_id: int,
        bio: str | None = None,
        price_per_hour: float | None = None,
        experience_years: int | None = None,
        sport_ids: list[int] | None = None,
    ) -> None:
        """Actualiza el perfil de profe; sport_ids (si viene) reemplaza el
        set completo de deportes en la misma transacción."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    sets, params, idx = [], [], 1
                    for col, val in (
                        ("bio", bio),
                        ("price_per_hour", price_per_hour),
                        ("experience_years", experience_years),
                    ):
                        if val is not None:
                            sets.append(f"{col} = ${idx}")
                            params.append(val); idx += 1
                    if sets:
                        params.append(teacher_id)
                        await connection.execute(
                            f"UPDATE {self.__table_name__} "
                            f"SET {', '.join(sets)} WHERE id = ${idx}",
                            *params,
                        )
                    if sport_ids is not None:
                        await connection.execute(
                            "DELETE FROM teacher_sport WHERE teacher_id = $1",
                            teacher_id,
                        )
                        for sid in sport_ids:
                            await connection.execute(
                                "INSERT INTO teacher_sport (teacher_id, sport_id) "
                                "VALUES ($1, $2) ON CONFLICT DO NOTHING",
                                teacher_id, sid,
                            )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    # -------- solicitudes --------

    async def get_latest_request(
        self, user_id: int
    ) -> TeacherRequestDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                row = await connection.fetchrow(
                    "SELECT * FROM teacher_request WHERE user_id = $1 "
                    "ORDER BY id DESC LIMIT 1",
                    user_id,
                )
                return _request_row_to_ddo(dict(row)) if row else None
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create_request(
        self,
        user_id: int,
        bio: str,
        price_per_hour: float,
        experience_years: int | None,
        sport_ids: list[int],
    ) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                await connection.execute(
                    "INSERT INTO teacher_request "
                    "(user_id, bio, price_per_hour, experience_years, "
                    "sport_ids_csv) VALUES ($1, $2, $3, $4, $5)",
                    user_id, bio, price_per_hour, experience_years,
                    ",".join(str(s) for s in sport_ids),
                )
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_pending_requests(self) -> list[TeacherRequestDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                rows = await connection.fetch(
                    "SELECT r.*, u.username, p.first_name, p.last_name "
                    "FROM teacher_request r "
                    "JOIN auth_user u ON u.id = r.user_id "
                    "LEFT JOIN player p ON p.user_id = r.user_id "
                    "WHERE r.status = 'pending' ORDER BY r.id",
                )
                return [_request_row_to_ddo(dict(r)) for r in rows]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def resolve_request_atomic(
        self, request_id: int, approve: bool
    ) -> int:
        """Aprueba (crea teacher + teacher_sport) o rechaza una solicitud
        pendiente, todo en una transacción. Devuelve el user_id del
        solicitante."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    req = await connection.fetchrow(
                        "SELECT * FROM teacher_request "
                        "WHERE id = $1 FOR UPDATE",
                        request_id,
                    )
                    if req is None:
                        raise TeacherNotFoundException(
                            message="No encontramos esa solicitud"
                        )
                    if req["status"] != "pending":
                        raise TeacherRequestException(
                            message="Esa solicitud ya fue resuelta",
                            error_code=409,
                        )
                    new_status = "approved" if approve else "rejected"
                    await connection.execute(
                        "UPDATE teacher_request SET status = $2 WHERE id = $1",
                        request_id, new_status,
                    )
                    if approve:
                        teacher_id = await connection.fetchval(
                            f"INSERT INTO {self.__table_name__} "
                            "(user_id, bio, price_per_hour, experience_years) "
                            "VALUES ($1, $2, $3, $4) RETURNING id",
                            req["user_id"], req["bio"],
                            req["price_per_hour"], req["experience_years"],
                        )
                        for sid in _csv_to_ids(req["sport_ids_csv"]):
                            await connection.execute(
                                "INSERT INTO teacher_sport "
                                "(teacher_id, sport_id) VALUES ($1, $2) "
                                "ON CONFLICT DO NOTHING",
                                teacher_id, sid,
                            )
                    return req["user_id"]
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
