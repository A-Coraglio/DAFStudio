from pydantic import BaseModel, Field


class CourtOutputDTO(BaseModel):
    id: int = Field(description="The court id")
    club_id: int | None = Field(default=None, description="Club owner (public court)")
    owner_id: int | None = Field(default=None, description="User owner (private court)")
    sport_id: int = Field(description="The sport id")
    name: str = Field(description="Court name")
    price_per_hour: float = Field(description="Price per hour")
    is_indoor: bool = Field(description="Indoor court")
    lat: float | None = Field(default=None, description="Latitude")
    lon: float | None = Field(default=None, description="Longitude")


class CreatePrivateCourtInputDTO(BaseModel):
    name: str = Field(description="Court name")
    sport_id: int = Field(description="The sport id")
    price_per_hour: float = Field(default=0.0, description="Price per hour (0 for backyard)")
    is_indoor: bool = Field(default=False, description="Indoor court")
    lat: float | None = Field(default=None, description="Latitude")
    lon: float | None = Field(default=None, description="Longitude")


class UpdatePrivateCourtInputDTO(BaseModel):
    name: str | None = Field(default=None)
    sport_id: int | None = Field(default=None)
    price_per_hour: float | None = Field(default=None)
    is_indoor: bool | None = Field(default=None)
    lat: float | None = Field(default=None)
    lon: float | None = Field(default=None)
