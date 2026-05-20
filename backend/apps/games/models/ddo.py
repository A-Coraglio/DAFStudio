from datetime import datetime
from pydantic import BaseModel, Field


class GameDDO(BaseModel):
    id: int = Field(description="The game id")
    name: str = Field(description="The game name / title")
    sport_id: int = Field(description="The sport id")
    organizer_id: int = Field(description="User who created the game")
    court_id: int | None = Field(default=None, description="Where it'll be played")
    max_players: int = Field(description="Max players allowed")
    level: str | None = Field(default=None, description="Required level")
    mode: str = Field(description="casual, competitive or matchmaking")
    status: str = Field(default="open", description="open, full, finished, cancelled")
    scheduled_at: datetime | None = Field(default=None, description="When it will be played")
    result_home: int | None = Field(default=None)
    result_away: int | None = Field(default=None)
    created_at: datetime = Field(description="Creation date")
    sport_name: str | None = Field(
        default=None,
        description="Sport display name — populated by list/get queries that "
        "JOIN the sports table; None on INSERT/UPDATE ... RETURNING rows.",
    )
    distance_km: float | None = Field(
        default=None,
        description="Distance from the caller's point to the game's court — "
        "populated by list_games when near_lat/near_lon are passed.",
    )
