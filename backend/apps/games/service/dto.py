from pydantic import BaseModel, Field

class UserOutputDTO(BaseModel):
    id : int = Field(description="The user id")
    name : str = Field(description="The user's name")