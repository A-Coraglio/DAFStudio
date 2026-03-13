from sqlmodel import SQLModel, Field
from datetime import datetime

class TournamentParticipant(SQLModel, table=True):
    tournament_id: int = Field(foreign_key="tournament.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    registered_at: datetime = Field(default_factory=datetime.utcnow)
