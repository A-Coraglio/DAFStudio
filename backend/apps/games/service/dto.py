from datetime import datetime
from pydantic import BaseModel, Field


GAME_MODES = ("casual", "competitive")


class GameCreateInputDTO(BaseModel):
    name: str = Field(description="Game name / title")
    sport_id: int = Field(description="The sport id")
    max_players: int = Field(description="Max players allowed")
    mode: str = Field(default="casual", description="casual or competitive")
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
    sport_name: str | None = None
    distance_km: float | None = None
    court_name: str | None = None
    court_lat: float | None = None
    court_lon: float | None = None
    # Whether the calling user participates. Populated on the list endpoint;
    # null elsewhere (the detail screen derives it from the roster).
    is_joined: bool | None = None
    organizer_id: int
    # Ranking of the organizer — the game's implicit skill anchor. The UI
    # warns joiners whose ranking falls outside ±500 of this value.
    organizer_ranking_points: int | None = None
    court_id: int | None = None
    max_players: int
    current_players: int = 0
    level: str | None = None
    mode: str
    status: str
    scheduled_at: str | None = None
    result_home: int | None = None
    result_away: int | None = None
    sets: str | None = None  # "6-4,6-3" for set sports; null otherwise
    created_at: str
    # Result-reporting progress: how many of the participants have already
    # submitted a confirmation. Only populated on the detail endpoint
    # (games_getter); list_games leaves these null to avoid N+1 queries.
    confirmations_count: int | None = None
    confirmations_total: int | None = None


class JoinGameInputDTO(BaseModel):
    team_id: int | None = Field(
        default=None, description="Optional team assignment"
    )
    position: int | None = Field(
        default=None, ge=0,
        description=(
            "Chosen slot (0..max_players-1). First half of the slots is the "
            "home side, the rest is away. Omit to join without a spot."
        ),
    )


class SetScoreDTO(BaseModel):
    home: int = Field(ge=0, description="Games won by home in this set")
    away: int = Field(ge=0, description="Games won by away in this set")


class ReportResultInputDTO(BaseModel):
    # Single-score sports (fútbol, básquet) send reported_home/reported_away.
    # Set-based sports (pádel, tenis, vóley) send `sets`; the backend derives
    # the sets-won that go into reported_home/reported_away.
    reported_home: int | None = Field(default=None, description="Score/sets for home")
    reported_away: int | None = Field(default=None, description="Score/sets for away")
    sets: list[SetScoreDTO] | None = Field(
        default=None, description="Per-set scores for set-based sports"
    )


class GamePlayerOutputDTO(BaseModel):
    """Row from `game_player` enriched with the player's profile so the
    detail screen can render "Juan Pérez · 1250 pts" without N+1 lookups."""
    game_id: int
    player_id: int
    team_id: int | None = None
    position: int | None = None
    created_at: str
    first_name: str | None = None
    last_name: str | None = None
    level: str | None = None
    ranking_points: int = 0
    avatar_url: str | None = None
