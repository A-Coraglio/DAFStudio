from datetime import datetime

from pydantic import BaseModel, Field, field_validator


class BookLessonInputDTO(BaseModel):
    teacher_id: int = Field(description="Teacher to book with")
    start_time: datetime = Field(description="User-local naive start time")
    end_time: datetime = Field(description="User-local naive end time")

    # Times follow the scheduled_at convention: user-local, naive. If a
    # client ever sends an offset we drop it instead of storing a mix.
    @field_validator("start_time", "end_time")
    @classmethod
    def _naive(cls, value: datetime) -> datetime:
        return value.replace(tzinfo=None)


class LessonOutputDTO(BaseModel):
    id: int = Field(description="The lesson id")
    teacher_id: int
    teacher_name: str
    student_id: int
    start_time: datetime
    end_time: datetime
    status: str = Field(description="pending / confirmed / cancelled")
    total_price: float


class BusySlotOutputDTO(BaseModel):
    """Occupied slot in a teacher's agenda (no student data)."""

    start_time: datetime
    end_time: datetime
