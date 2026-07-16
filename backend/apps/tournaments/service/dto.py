from datetime import datetime

from pydantic import BaseModel, Field


class TournamentOutputDTO(BaseModel):
    id: int = Field(description="The tournament id")
    organizer_id: int
    sport_id: int
    club_id: int | None = None
    name: str
    description: str | None = None
    start_date: datetime
    end_date: datetime
    max_participants: int
    status: str = Field(description="upcoming / ongoing / finished")
    level: str | None = Field(default=None, description="Target level")
    lat: float | None = None
    lon: float | None = None
    participant_count: int = Field(default=0)
    distance_km: float | None = Field(
        default=None, description="Km from the query origin, when provided"
    )
