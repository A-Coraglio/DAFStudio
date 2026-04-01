from datetime import datetime, timezone
from sqlmodel import SQLModel, Field

class Lesson(SQLModel, table=True):
    __tablename__ = "lesson" # type: ignore
    id: int = Field(primary_key=True, index=True)
    teacher_id: int = Field(foreign_key="teacher.id")
    student_id: int = Field(foreign_key="player.id")
    # sport_id: int = Field(foreign_key="sports.id")
    # court_id: int | None = Field(foreign_key="court.id", default=None)
    start_time: datetime
    end_time: datetime
    status: str = Field(default="pending")  # pending, confirmed, cancelled
    total_price: float
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
