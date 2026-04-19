from pydantic import BaseModel, Field


class CourtDDO(BaseModel):
    id: int = Field(description="The court id")
    club_id: int | None = Field(
        default=None,
        description="Club that owns this court. Null if privately owned.",
    )
    owner_id: int | None = Field(
        default=None,
        description="User that owns this court. Null if belongs to a club.",
    )
    sport_id: int = Field(description="The sport id")
    name: str = Field(description="Court name")
    price_per_hour: float = Field(description="Price per hour (0 for private backyards)")
    is_indoor: bool = Field(description="Indoor court")
    lat: float | None = Field(default=None, description="Latitude")
    lon: float | None = Field(default=None, description="Longitude")
