from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.lessons.models import GeneralModel
from apps.lessons.models.ddo import BusySlotDDO, LessonDDO
from apps.lessons.exceptions.exceptions import (
    LessonNotFoundException,
    LessonStateException,
)
from apps.common.exceptions.exceptions import AppException, DatabaseException


def _row_to_ddo(row) -> LessonDDO:
    name = " ".join(
        p for p in (row["first_name"], row["last_name"]) if p
    ).strip()
    return LessonDDO(
        id=row["id"],
        teacher_id=row["teacher_id"],
        student_id=row["student_id"],
        sport_id=row.get("sport_id"),
        start_time=row["start_time"],
        end_time=row["end_time"],
        status=row["status"],
        total_price=row["total_price"],
        created_at=row["created_at"],
        teacher_name=name if name else row["username"],
    )


class LessonModel(GeneralModel):
    __table_name__ = "lesson"

    # Teacher name resolved like in classes: player name, username fallback.
    _BASE_SELECT = (
        "SELECT l.*, u.username, p.first_name, p.last_name "
        "FROM lesson l "
        "JOIN teacher t ON t.id = l.teacher_id "
        "JOIN auth_user u ON u.id = t.user_id "
        "LEFT JOIN player p ON p.user_id = t.user_id "
    )

    async def list_for_student(self, student_id: int) -> list[LessonDDO]:
        """All the student's lessons, soonest upcoming first, then the past
        ones (most recent first)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"{self._BASE_SELECT}"
                "WHERE l.student_id = $1 "
                "ORDER BY (l.end_time >= now()::timestamp) DESC, "
                "CASE WHEN l.end_time >= now()::timestamp "
                "THEN l.start_time END ASC, l.start_time DESC"
            )
            try:
                results = await connection.fetch(query, student_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def busy_slots(self, teacher_id: int) -> list[BusySlotDDO]:
        """Upcoming non-cancelled slots of a teacher's agenda."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                "SELECT start_time, end_time FROM lesson "
                "WHERE teacher_id = $1 AND status <> 'cancelled' "
                "AND end_time >= now()::timestamp "
                "ORDER BY start_time"
            )
            try:
                results = await connection.fetch(query, teacher_id)
                return [
                    BusySlotDDO(
                        start_time=r["start_time"], end_time=r["end_time"]
                    )
                    for r in results
                ]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def book_atomic(
        self,
        teacher_id: int,
        student_id: int,
        start_time: datetime,
        end_time: datetime,
        total_price: float,
        sport_id: int | None = None,
    ) -> int:
        """Single-transaction booking. Locks the teacher row (FOR UPDATE) so
        two concurrent bookings can't take overlapping slots — the overlap
        check and the insert see a frozen agenda. Returns the new lesson id.

        Bookings are born 'confirmed': there is no teacher-side flow yet to
        confirm them ('pending' is reserved for when that exists)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    await connection.fetchrow(
                        "SELECT id FROM teacher WHERE id = $1 FOR UPDATE",
                        teacher_id,
                    )
                    clash = await connection.fetchrow(
                        f"SELECT 1 FROM {self.__table_name__} "
                        "WHERE teacher_id = $1 AND status <> 'cancelled' "
                        "AND start_time < $3 AND end_time > $2",
                        teacher_id, start_time, end_time,
                    )
                    if clash:
                        raise LessonStateException(
                            message="El profe ya tiene una clase en ese horario"
                        )
                    return await connection.fetchval(
                        f"INSERT INTO {self.__table_name__} "
                        "(teacher_id, student_id, sport_id, start_time, "
                        "end_time, status, total_price) "
                        "VALUES ($1, $2, $3, $4, $5, 'confirmed', $6) "
                        "RETURNING id",
                        teacher_id, student_id, sport_id, start_time,
                        end_time, total_price,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_by_id(self, lesson_id: int) -> LessonDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"{self._BASE_SELECT}WHERE l.id = $1"
            try:
                result = await connection.fetchrow(query, lesson_id)
                if result is None:
                    raise LessonNotFoundException(
                        message=f"No encontramos la clase {lesson_id}"
                    )
                return _row_to_ddo(result)
            except LessonNotFoundException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def cancel_atomic(self, lesson_id: int, student_id: int) -> None:
        """Student-side cancellation. Ownership is checked in the same lock
        as the update; a lesson of another student reads as a 404 so ids
        can't be probed."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    lesson = await connection.fetchrow(
                        f"SELECT student_id, status, start_time "
                        f"FROM {self.__table_name__} WHERE id = $1 FOR UPDATE",
                        lesson_id,
                    )
                    if lesson is None or lesson["student_id"] != student_id:
                        raise LessonNotFoundException(
                            message=f"No encontramos la clase {lesson_id}"
                        )
                    if lesson["status"] == "cancelled":
                        raise LessonStateException(
                            message="Esta clase ya está cancelada"
                        )
                    if lesson["start_time"] <= datetime.now():
                        raise LessonStateException(
                            message="Esta clase ya pasó: no es posible cancelarla"
                        )
                    await connection.execute(
                        f"UPDATE {self.__table_name__} "
                        "SET status = 'cancelled' WHERE id = $1",
                        lesson_id,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
