from sqlmodel import SQLModel, Field


class PlayerSportStat(SQLModel, table=True):
    __tablename__ = "player_sport_stat"  # type: ignore
    player_id: int = Field(foreign_key="player.id", primary_key=True)
    sport_id: int = Field(foreign_key="sports.id", primary_key=True)
    # ELO-like ranking for this player IN this sport. New (player, sport)
    # pairs start at 1000.
    ranking_points: int = Field(default=1000)
