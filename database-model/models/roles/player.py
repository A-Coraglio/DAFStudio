from sqlmodel import SQLModel, Field

class Player(SQLModel, table=True):
    __tablename__ = "player"
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True)
    level: str | None = Field(max_length=20, default=None)  # "beginner", "intermediate", "advanced"
    ranking_points: int = Field(default=0)