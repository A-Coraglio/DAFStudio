from sqlmodel import SQLModel, Field


class SportMode(SQLModel, table=True):
    """A specific "modalidad" within a sport — e.g. sport=Fútbol has modes
    F5 (5-a-side), F7, F11; sport=Tenis has modes Singles, Dobles.

    Exists alongside `sports` as a scaffold — current `game`/`matchmaking_ticket`
    rows still reference `sports.id` directly. Callers can opt-in by adding
    a nullable `sport_mode_id` column on their own schedule.
    """
    __tablename__ = "sport_mode"  # type: ignore
    id: int = Field(primary_key=True)
    sport_id: int = Field(foreign_key="sports.id", index=True)
    name: str = Field(max_length=50)
    max_players_per_team: int
