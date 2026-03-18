from sqlmodel import SQLModel, Field

class Sport(SQLModel, table=True):
    id: int = Field(primary_key=True)
    name: str = Field(max_length=50)  # "padel", "tennis", "football"
    max_players_per_team: int