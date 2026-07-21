from datetime import datetime

from pydantic import BaseModel, Field


class LessonDDO(BaseModel):
    """A booked lesson (row of `lesson`), joined with the teacher's display
    name so "mis clases" doesn't need a second query."""

    id: int = Field(description="The lesson id")
    teacher_id: int = Field(description="FK to teacher")
    student_id: int = Field(description="FK to player")
    sport_id: int | None = Field(
        default=None, description="Sport of the lesson (None = not chosen)"
    )
    start_time: datetime
    end_time: datetime
    status: str = Field(description="pending / confirmed / cancelled")
    total_price: float
    created_at: datetime
    teacher_name: str = Field(description="Teacher's name (or username fallback)")


class BusySlotDDO(BaseModel):
    """An occupied slot in a teacher's agenda — no personal data on purpose,
    it's shown to any student browsing the teacher's availability."""

    start_time: datetime
    end_time: datetime
