from datetime import datetime
from sqlmodel import SQLModel, Field

class Game(SQLModel, table=True):
    id: int = Field(primary_key=True, index=True)
    booking_id: int | None = Field(foreign_key="booking.id", default=None)
    sport_id: int = Field(foreign_key="sports.id")
    organizer_id: int = Field(foreign_key="user.id")
    max_players: int
    level: str | None = Field(max_length=20, default=None)
    status: str = Field(default="open")  # open, full, finished
    created_at: datetime = Field(default_factory=datetime.utcnow)