from datetime import datetime

from pydantic import BaseModel, Field


class TournamentDDO(BaseModel):
    id: int = Field(description="The tournament id")
    organizer_id: int = Field(description="FK to auth_user (organizer)")
    sport_id: int = Field(description="FK to sports")
    club_id: int | None = Field(default=None, description="FK to club, if hosted at one")
    name: str = Field(description="Tournament name")
    description: str | None = Field(default=None)
    start_date: datetime
    end_date: datetime
    max_participants: int
    status: str = Field(description="upcoming / ongoing / finished")
    level: str | None = Field(
        default=None, description="Target level: beginner / intermediate / advanced"
    )
    lat: float | None = Field(default=None)
    lon: float | None = Field(default=None)
    participant_count: int = Field(default=0, description="Currently enrolled players")
    distance_km: float | None = Field(
        default=None, description="Distance from the query origin, when provided"
    )
