from sqlmodel import SQLModel, Field

class Team(SQLModel, table=True):
    __tablename__ = "team" # type: ignore
    id: int = Field(primary_key=True)
    name: str = Field(max_length=50)
    sport_id: int = Field(foreign_key="sports.id")