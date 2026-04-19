from datetime import datetime
from pydantic import BaseModel, Field


GAME_MODES = ("casual", "competitive", "matchmaking")


class GameCreateInputDTO(BaseModel):
    name: str = Field(description="Game name / title")
    sport_id: int = Field(description="The sport id")
    max_players: int = Field(description="Max players allowed")
    mode: str = Field(default="casual", description="casual, competitive or matchmaking")
    court_id: int | None = Field(default=None)
    level: str | None = Field(default=None)
    scheduled_at: datetime | None = Field(default=None)


class GameUpdateInputDTO(BaseModel):
    name: str | None = Field(default=None)
    max_players: int | None = Field(default=None)
    court_id: int | None = Field(default=None)
    level: str | None = Field(default=None)
    scheduled_at: datetime | None = Field(default=None)
    status: str | None = Field(default=None)


class GamesOutputDTO(BaseModel):
    id: int
    name: str
    sport_id: int
    organizer_id: int
    court_id: int | None = None
    max_players: int
    current_players: int = 0
    level: str | None = None
    mode: str
    status: str
    scheduled_at: str | None = None
    result_home: int | None = None
    result_away: int | None = None
    created_at: str


class JoinGameInputDTO(BaseModel):
    team_id: int | None = Field(
        default=None, description="Optional team assignment"
    )


class ReportResultInputDTO(BaseModel):
    reported_home: int = Field(description="Score for home team")
    reported_away: int = Field(description="Score for away team")


class GamePlayerOutputDTO(BaseModel):
    """Row from `game_player` enriched with the player's profile so the
    detail screen can render "Juan Pérez · 1250 pts" without N+1 lookups."""
    game_id: int
    player_id: int
    team_id: int | None = None
    created_at: str
    first_name: str | None = None
    last_name: str | None = None
    level: str | None = None
    ranking_points: int = 0
