from datetime import datetime
from pydantic import BaseModel, Field

from apps.games.service.dto import GamesOutputDTO


class QueueInputDTO(BaseModel):
    sport_id: int
    max_radius_km: float = Field(description="Max distance in km from origin")
    origin_lat: float
    origin_lon: float
    window_start: datetime
    window_end: datetime


class TicketOutputDTO(BaseModel):
    id: int
    user_id: int
    sport_id: int
    max_radius_km: float
    origin_lat: float
    origin_lon: float
    window_start: str
    window_end: str
    status: str
    matched_game_id: int | None = None
    created_at: str


class StatusOutputDTO(BaseModel):
    """What the frontend polls while in queue."""
    ticket: TicketOutputDTO | None = Field(
        default=None,
        description="Current active ticket, if any",
    )
    proposed_game: GamesOutputDTO | None = Field(
        default=None,
        description="Game proposal pending acceptance, if ticket status is 'proposed' or 'accepted'",
    )


class RunMatcherOutputDTO(BaseModel):
    matches_created: int
