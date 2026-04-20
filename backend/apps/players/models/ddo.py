from pydantic import BaseModel, Field


class PlayerDDO(BaseModel):
    id: int = Field(description="The player id")
    user_id: int = Field(description="FK to auth_user")
    first_name: str | None = Field(default=None)
    last_name: str | None = Field(default=None)
    level: str | None = Field(
        default=None,
        description="Self-reported level: beginner, intermediate, advanced",
    )
    ranking_points: int = Field(default=0, description="ELO-like ranking")
    favorite_sport_id: int | None = Field(
        default=None,
        description="Sport the user picked during onboarding",
    )
    avatar_path: str | None = Field(
        default=None,
        description="Relative path under /uploads/ (e.g. avatars/123.png)",
    )
