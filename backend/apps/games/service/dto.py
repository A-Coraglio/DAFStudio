from pydantic import BaseModel, Field

class GamesOutputDTO(BaseModel):
    id : int = Field(description="The user id")
    name : str = Field(description="The user's name")


class TournamentOutputDTO(BaseModel):
    id : int = Field(description="The user id")
    name : str = Field(description="The user's name")