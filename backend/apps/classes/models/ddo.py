from pydantic import BaseModel, Field


class ClassDDO(BaseModel):
    """A "class" offering = a teacher the user can take lessons with. Location
    is the teacher's home point (auth_user.home_lat/lon)."""

    id: int = Field(description="The teacher id")
    user_id: int = Field(description="FK to auth_user")
    display_name: str = Field(description="Teacher's name (or username fallback)")
    bio: str | None = Field(default=None)
    price_per_hour: float = Field(description="Lesson price per hour")
    experience_years: int | None = Field(default=None)
    sport_ids: list[int] = Field(default_factory=list, description="Sports taught")
    lat: float | None = Field(default=None)
    lon: float | None = Field(default=None)
    distance_km: float | None = Field(default=None)
