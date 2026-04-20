from pydantic import BaseModel, Field


class SportModeCreateInputDTO(BaseModel):
    sport_id: int
    name: str = Field(max_length=50)
    max_players_per_team: int


class SportModeOutputDTO(BaseModel):
    id: int
    sport_id: int
    name: str
    max_players_per_team: int
