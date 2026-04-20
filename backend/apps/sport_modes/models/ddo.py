from pydantic import BaseModel, Field


class SportModeDDO(BaseModel):
    id: int = Field(description="Sport mode id")
    sport_id: int = Field(description="Parent sport id")
    name: str = Field(description="Mode name, e.g. 'F5', 'F11', 'Singles'")
    max_players_per_team: int
