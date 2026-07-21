from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func


class CourtSlot(SQLModel, table=True):
    """Turno de una cancha de club. El organizador los crea/quita/bloquea;
    los jugadores reservan los libres (sin pago por ahora).

    status: free (reservable) | booked (reservado por booked_by_player_id) |
    blocked (ocupado a mano por el club — reserva telefónica, mantenimiento).
    Horarios naive user-local, como scheduled_at/lesson."""

    __tablename__ = "court_slot"  # type: ignore
    id: int = Field(primary_key=True)
    court_id: int = Field(foreign_key="court.id")
    start_time: datetime
    end_time: datetime
    status: str = Field(default="free", max_length=10)
    booked_by_player_id: int | None = Field(
        foreign_key="player.id", default=None
    )
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
