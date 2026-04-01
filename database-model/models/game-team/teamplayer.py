from sqlmodel import SQLModel, Field

class TeamPlayer(SQLModel, table=True):
    __tablename__ = "team_player" # type: ignore
    team_id: int = Field(foreign_key="team.id", primary_key=True)
    player_id: int = Field(foreign_key="player.id", primary_key=True)