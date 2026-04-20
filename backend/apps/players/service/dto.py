from pydantic import BaseModel, Field


class PlayerOutputDTO(BaseModel):
    id: int = Field(description="The player id")
    user_id: int = Field(description="FK to auth_user")
    first_name: str | None = Field(default=None)
    last_name: str | None = Field(default=None)
    level: str | None = Field(default=None, description="beginner, intermediate, advanced")
    ranking_points: int = Field(description="ELO-like ranking (visible)")
    favorite_sport_id: int | None = Field(default=None)
    avatar_url: str | None = Field(
        default=None,
        description="Absolute URL for the avatar image, or null if unset",
    )


class UpdatePlayerInputDTO(BaseModel):
    first_name: str | None = Field(default=None)
    last_name: str | None = Field(default=None)
    level: str | None = Field(default=None)
    favorite_sport_id: int | None = Field(default=None)
