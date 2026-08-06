from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func

class Game(SQLModel, table=True):
    __tablename__ = "game" # type: ignore
    id: int = Field(primary_key=True, index=True)
    name: str = Field(max_length=100)
    sport_id: int = Field(foreign_key="sports.id")
    organizer_id: int = Field(foreign_key="auth_user.id")
    # court_id is nullable: matchmaking games resolve the court only when the
    court_id: int | None = Field(foreign_key="court.id", default=None)
    max_players: int
    level: str | None = Field(max_length=20, default=None)
    # "casual" = social, no ranking points. "competitive" = awards ELO.
    # Matchmaking-created games carry the mode their tickets requested — the
    # mechanism of creation (manual vs queue) is no longer encoded here.
    mode: str = Field(default="casual", max_length=20)
    status: str = Field(default="open")  # open, full, finished, cancelled
    scheduled_at: datetime | None = Field(default=None)
    # Final score. Filled once a quorum of players reports the same result
    # via game_result_confirmation. Null while the match is pending / in-flight.
    result_home: int | None = Field(default=None)
    result_away: int | None = Field(default=None)
    # Per-set detail for set-based sports, e.g. "6-4,6-3". Null for
    # single-score sports. result_home/away hold the count of sets won.
    sets: str | None = Field(default=None, max_length=100)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
