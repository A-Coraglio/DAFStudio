from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy
from pydantic import BaseModel, Field

from apps.courts.models import GeneralModel
from apps.common.exceptions.exceptions import (
    AppException,
    DatabaseException,
    NotFoundException,
)


class SlotStateException(AppException):
    """Turno en un estado que no permite la acción (ya reservado, pasado,
    solapado, etc.)."""

    def __init__(
        self,
        message: str = "Ese turno no permite esa acción",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class CourtSlotDDO(BaseModel):
    id: int
    court_id: int
    start_time: datetime
    end_time: datetime
    status: str = Field(description="free / booked / blocked")
    booked_by_player_id: int | None = None
    booked_by_name: str | None = Field(
        default=None, description="Nombre del jugador que reservó (vista club)"
    )
    # Solo en "mis turnos": contexto de dónde es el turno.
    court_name: str | None = None
    club_name: str | None = None
    sport_id: int | None = None


def _row_to_ddo(row) -> CourtSlotDDO:
    booked_name = " ".join(
        p for p in (row.get("b_first_name"), row.get("b_last_name")) if p
    ).strip()
    return CourtSlotDDO(
        id=row["id"],
        court_id=row["court_id"],
        start_time=row["start_time"],
        end_time=row["end_time"],
        status=row["status"],
        booked_by_player_id=row["booked_by_player_id"],
        booked_by_name=booked_name if booked_name else None,
        court_name=row.get("court_name"),
        club_name=row.get("club_name"),
        sport_id=row.get("c_sport_id"),
    )


class CourtSlotModel(GeneralModel):
    __table_name__ = "court_slot"

    _SELECT = (
        "SELECT s.*, b.first_name AS b_first_name, b.last_name AS b_last_name "
        "FROM court_slot s "
        "LEFT JOIN player b ON b.id = s.booked_by_player_id "
    )

    async def list_slots(
        self, court_id: int, upcoming_only: bool = True
    ) -> list[CourtSlotDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            extra = "AND s.end_time >= now()::timestamp" if upcoming_only else ""
            query = (
                f"{self._SELECT} WHERE s.court_id = $1 {extra} "
                "ORDER BY s.start_time"
            )
            try:
                rows = await connection.fetch(query, court_id)
                return [_row_to_ddo(r) for r in rows]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def create_slot(
        self, court_id: int, start_time: datetime, end_time: datetime
    ) -> CourtSlotDDO:
        """Alta con chequeo de solapamiento contra los turnos de la cancha,
        bajo lock de la cancha (dos altas concurrentes no se pisan)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    await connection.fetchrow(
                        "SELECT id FROM court WHERE id = $1 FOR UPDATE",
                        court_id,
                    )
                    clash = await connection.fetchrow(
                        f"SELECT 1 FROM {self.__table_name__} "
                        "WHERE court_id = $1 AND start_time < $3 "
                        "AND end_time > $2",
                        court_id, start_time, end_time,
                    )
                    if clash:
                        raise SlotStateException(
                            message="Ya hay un turno que se pisa con ese horario"
                        )
                    row = await connection.fetchrow(
                        f"INSERT INTO {self.__table_name__} "
                        "(court_id, start_time, end_time) "
                        "VALUES ($1, $2, $3) RETURNING *",
                        court_id, start_time, end_time,
                    )
                    return _row_to_ddo(dict(row))
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def get_slot(self, slot_id: int) -> CourtSlotDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                row = await connection.fetchrow(
                    f"{self._SELECT} WHERE s.id = $1", slot_id
                )
                if row is None:
                    raise NotFoundException(
                        message=f"No encontramos el turno {slot_id}"
                    )
                return _row_to_ddo(row)
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def delete_slot(self, slot_id: int) -> None:
        """Quitar un turno. Uno reservado no se borra: primero liberarlo
        (para que el club sea consciente de que pisa una reserva)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    row = await connection.fetchrow(
                        f"SELECT status FROM {self.__table_name__} "
                        "WHERE id = $1 FOR UPDATE",
                        slot_id,
                    )
                    if row is None:
                        raise NotFoundException(
                            message=f"No encontramos el turno {slot_id}"
                        )
                    if row["status"] == "booked":
                        raise SlotStateException(
                            message="El turno está reservado: liberalo antes de quitarlo"
                        )
                    await connection.execute(
                        f"DELETE FROM {self.__table_name__} WHERE id = $1",
                        slot_id,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def set_status(self, slot_id: int, status: str) -> None:
        """Bloquear (ocupado a mano) o liberar. Ambas limpian la reserva."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                row = await connection.fetchrow(
                    f"UPDATE {self.__table_name__} "
                    "SET status = $2, booked_by_player_id = NULL "
                    "WHERE id = $1 RETURNING id",
                    slot_id, status,
                )
                if row is None:
                    raise NotFoundException(
                        message=f"No encontramos el turno {slot_id}"
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def book_atomic(self, slot_id: int, player_id: int) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    row = await connection.fetchrow(
                        f"SELECT status, start_time FROM {self.__table_name__} "
                        "WHERE id = $1 FOR UPDATE",
                        slot_id,
                    )
                    if row is None:
                        raise NotFoundException(
                            message=f"No encontramos el turno {slot_id}"
                        )
                    if row["start_time"] <= datetime.now():
                        raise SlotStateException(message="Ese turno ya pasó")
                    if row["status"] != "free":
                        raise SlotStateException(
                            message="Ese turno ya no está libre"
                        )
                    await connection.execute(
                        f"UPDATE {self.__table_name__} SET status = 'booked', "
                        "booked_by_player_id = $2 WHERE id = $1",
                        slot_id, player_id,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def cancel_booking_atomic(
        self, slot_id: int, player_id: int
    ) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    row = await connection.fetchrow(
                        f"SELECT status, booked_by_player_id, start_time "
                        f"FROM {self.__table_name__} WHERE id = $1 FOR UPDATE",
                        slot_id,
                    )
                    if row is None or row["booked_by_player_id"] != player_id:
                        raise NotFoundException(
                            message="No encontramos esa reserva tuya"
                        )
                    if row["start_time"] <= datetime.now():
                        raise SlotStateException(
                            message="Ese turno ya pasó: no se puede cancelar"
                        )
                    await connection.execute(
                        f"UPDATE {self.__table_name__} SET status = 'free', "
                        "booked_by_player_id = NULL WHERE id = $1",
                        slot_id,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def list_bookings_by_player(
        self, player_id: int
    ) -> list[CourtSlotDDO]:
        """Mis turnos reservados (próximos primero), con cancha y club."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                "SELECT s.*, NULL AS b_first_name, NULL AS b_last_name, "
                "c.name AS court_name, c.sport_id AS c_sport_id, "
                "cl.name AS club_name "
                "FROM court_slot s "
                "JOIN court c ON c.id = s.court_id "
                "LEFT JOIN club cl ON cl.id = c.club_id "
                "WHERE s.booked_by_player_id = $1 "
                "AND s.end_time >= now()::timestamp "
                "ORDER BY s.start_time"
            )
            try:
                rows = await connection.fetch(query, player_id)
                return [_row_to_ddo(r) for r in rows]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
