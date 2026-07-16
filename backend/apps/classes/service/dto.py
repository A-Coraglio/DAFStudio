from pydantic import BaseModel, Field


class ClassOutputDTO(BaseModel):
    """A teacher offering classes, as shown in the "find classes" carousel and
    search screen."""

    id: int = Field(description="The teacher id")
    user_id: int
    display_name: str
    bio: str | None = None
    price_per_hour: float
    experience_years: int | None = None
    sport_ids: list[int] = Field(default_factory=list)
    lat: float | None = None
    lon: float | None = None
    distance_km: float | None = None
