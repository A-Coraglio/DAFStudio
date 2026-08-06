from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func

class Lesson(SQLModel, table=True):
    __tablename__ = "lesson" # type: ignore
    id: int = Field(primary_key=True, index=True)
    teacher_id: int = Field(foreign_key="teacher.id")
    student_id: int = Field(foreign_key="player.id")
    # Deporte de la clase (opcional: NULL = lecciones viejas / profe de un
    # solo deporte donde no se eligió). Agregado 2026-07-21 (c0d1e2f3a4b5).
    sport_id: int | None = Field(foreign_key="sports.id", default=None)
    # court_id queda para cuando exista un flujo de elegir cancha para clases:
    # court_id: int | None = Field(foreign_key="court.id", default=None)
    start_time: datetime
    end_time: datetime
    status: str = Field(default="pending")  # pending, confirmed, cancelled
    total_price: float
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
