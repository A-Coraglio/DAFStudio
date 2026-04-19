from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func


class MatchmakingTicket(SQLModel, table=True):
    """A user's request to be matched into a game.

    The worker reads waiting tickets, groups them by sport + geographic
    overlap + time-window overlap, and when enough compatible players are
    found creates a `game` (mode=matchmaking) and flips the tickets to
    status="matched" with matched_game_id set.
    """
    __tablename__ = "matchmaking_ticket" # type: ignore
    id: int = Field(primary_key=True, index=True)
    user_id: int = Field(foreign_key="auth_user.id", index=True)
    sport_id: int = Field(foreign_key="sports.id", index=True)
    max_radius_km: float
    origin_lat: float
    origin_lon: float
    # When the user wants to play. Frontend offers presets ("now",
    # "next hour", "today") but stores concrete timestamps.
    window_start: datetime
    window_end: datetime
    status: str = Field(default="waiting", max_length=20)  # waiting, matched, cancelled, expired
    matched_game_id: int | None = Field(foreign_key="game.id", default=None)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
