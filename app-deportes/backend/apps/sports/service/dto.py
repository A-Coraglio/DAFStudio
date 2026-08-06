from pydantic import BaseModel, Field


class SportOutputDTO(BaseModel):
    id: int = Field(description="The sport id")
    name: str = Field(description="The sport name")
    max_players_per_team: int = Field(description="Max players per team for this sport")
