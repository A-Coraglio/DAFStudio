from pydantic import BaseModel, Field


class GameCreateDTO(BaseModel):
    sport_id: int = Field(description="The sport id")

class GamesOutputDTO(BaseModel):
    id : int = Field(description="The user id")
    name : str = Field(description="The user's name")
    sport_id: int = Field(description="The sport id")
    organizer_id: int = Field(description="The organizer id")
    max_players: int = Field(description="Max players allowed")
    level: str | None = Field(default=None, description="Game level")
    status: str = Field(default="open", description="Game status")
    created_at: str = Field(description="Creation date")

class TournamentOutputDTO(BaseModel):
    id : int = Field(description="The user id")
    name : str = Field(description="The user's name")