from datetime import datetime, timezone
from sqlmodel import SQLModel, Field

class GameResultConfirmation(SQLModel, table=True):
    __tablename__ = "game_result_confirmation" # type: ignore
    game_id: int = Field(foreign_key="game.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    reported_home: int
    reported_away: int
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
