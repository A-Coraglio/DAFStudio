from pydantic import BaseModel, Field


class ClubOutputDTO(BaseModel):
    id: int = Field(description="The club id")
    owner_id: int = Field(description="User who owns this club")
    name: str = Field(description="Club name")
    address: str = Field(description="Street address")
    city: str = Field(description="City")
    description: str | None = Field(default=None, description="Optional description")


class CreateClubInputDTO(BaseModel):
    # Alta solo por admin (2026-07-21): el admin elige quién es el dueño.
    owner_user_id: int = Field(description="Usuario dueño/organizador del club")
    name: str = Field(description="Club name")
    address: str = Field(description="Street address")
    city: str = Field(description="City")
    description: str | None = Field(default=None, description="Optional description")


class UpdateClubInputDTO(BaseModel):
    name: str | None = Field(default=None)
    address: str | None = Field(default=None)
    city: str | None = Field(default=None)
    description: str | None = Field(default=None)
