from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func
from datetime import datetime, timezone

class TournamentParticipant(SQLModel, table=True):
    __tablename__ = "tournament_participant" # type: ignore
    tournament_id: int = Field(foreign_key="tournament.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
