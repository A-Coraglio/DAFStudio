from datetime import datetime
from sqlmodel import SQLModel, Field

class Tournament(SQLModel, table=True):
    id: int = Field(primary_key=True, index=True)
    organizer_id: int = Field(foreign_key="user.id")
    # sport_id: int = Field(foreign_key="sports.id")
    # club_id: int | None = Field(foreign_key="club.id", default=None)
    name: str = Field(max_length=100)
    description: str | None = None
    start_date: datetime
    end_date: datetime
    max_participants: int
    status: str = Field(default="upcoming")  # upcoming, ongoing, finished
