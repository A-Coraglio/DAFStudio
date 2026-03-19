from datetime import datetime, timezone
from sqlmodel import SQLModel, Field

class Game(SQLModel, table=True):
    __tablename__ = "game"
    id: int = Field(primary_key=True, index=True)
    name: str = Field(max_length=100)
    # booking_id: int | None = Field(foreign_key="booking.id", default=None)
    sport_id: int = Field(foreign_key="sports.id")
    organizer_id: int = Field(foreign_key="user.id")
    max_players: int
    level: str | None = Field(max_length=20, default=None)
    status: str = Field(default="open")  # open, full, finished
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
