from datetime import datetime, timezone
from sqlmodel import SQLModel, Field

class GamePlayer(SQLModel, table=True):
    __tablename__ = "game_player"
    game_id: int = Field(foreign_key="game.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    team_id: int | None = Field(foreign_key="team.id", default=None)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
