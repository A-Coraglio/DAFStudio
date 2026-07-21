from datetime import datetime

from pydantic import BaseModel, Field, field_validator


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


class CreateSlotInputDTO(BaseModel):
    start_time: datetime = Field(description="User-local naive start time")
    end_time: datetime = Field(description="User-local naive end time")

    # Misma convención naive user-local que lessons/scheduled_at.
    @field_validator("start_time", "end_time")
    @classmethod
    def _naive(cls, value: datetime) -> datetime:
        return value.replace(tzinfo=None)


class CourtSlotOutputDTO(BaseModel):
    id: int
    court_id: int
    start_time: datetime
    end_time: datetime
    status: str = Field(description="free / booked / blocked")
    booked_by_player_id: int | None = None
    # Nombre del que reservó — solo lo ve el dueño de la cancha/club.
    booked_by_name: str | None = None
    # Contexto — solo en /courts/my-bookings/.
    court_name: str | None = None
    club_name: str | None = None
    sport_id: int | None = None
