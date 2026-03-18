from sqlmodel import SQLModel, Field

class Teacher(SQLModel, table=True):
    __tablename__ = "teacher"
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True)
    bio: str | None = None
    price_per_hour: float
    experience_years: int | None = None