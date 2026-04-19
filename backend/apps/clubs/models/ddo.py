from pydantic import BaseModel, Field


class ClubDDO(BaseModel):
    id: int = Field(description="The club id")
    owner_id: int = Field(description="User who owns this club")
    name: str = Field(description="Club name")
    address: str = Field(description="Street address")
    city: str = Field(description="City")
    description: str | None = Field(default=None, description="Optional description")
