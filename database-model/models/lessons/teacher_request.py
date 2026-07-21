from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func


class TeacherRequest(SQLModel, table=True):
    """Solicitud "quiero ser profe": el jugador manda su perfil propuesto y
    un admin la aprueba (crea teacher + teacher_sport) o la rechaza."""

    __tablename__ = "teacher_request"  # type: ignore
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="auth_user.id")
    bio: str
    price_per_hour: float
    experience_years: int | None = Field(default=None)
    # CSV de sport ids ("1,3") — dato transitorio de la cola, no vale la
    # pena una tabla puente para algo que muere al resolverse.
    sport_ids_csv: str = Field(max_length=100)
    status: str = Field(default="pending", max_length=10)  # pending/approved/rejected
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
