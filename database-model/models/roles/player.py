from sqlmodel import SQLModel, Field

class Player(SQLModel, table=True):
    __tablename__ = "player" # type: ignore
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="auth_user.id", unique=True)
    # Display identity: the user fills these in after registering, in the
    # "complete profile" onboarding step.
    first_name: str | None = Field(max_length=50, default=None)
    last_name: str | None = Field(max_length=50, default=None)
    level: str | None = Field(max_length=20, default=None)  # "beginner", "intermediate", "advanced"
    ranking_points: int = Field(default=0)
    favorite_sport_id: int | None = Field(foreign_key="sports.id", default=None)
