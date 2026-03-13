from datetime import datetime
from sqlmodel import SQLModel, Field

class GamePlayer(SQLModel, table=True):
    game_id: int = Field(foreign_key="game.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    team_id: int | None = Field(foreign_key="team.id", default=None)
    joined_at: datetime = Field(default_factory=datetime.utcnow)