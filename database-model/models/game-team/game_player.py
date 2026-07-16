from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func

class GamePlayer(SQLModel, table=True):
    __tablename__ = "game_player" # type: ignore
    game_id: int = Field(foreign_key="game.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    team_id: int | None = Field(foreign_key="team.id", default=None)
    # Chosen slot (0..max_players-1); first half = home side. NULL = no
    # preference, balanced by join order when the game settles.
    position: int | None = Field(default=None)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
