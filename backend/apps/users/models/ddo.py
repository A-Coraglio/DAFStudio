from datetime import datetime
from pydantic import BaseModel, Field

class UserDDO(BaseModel):
    id: int
    username: str
    email: str
    password_hash: str
    # False = provisioned via Google with a random hash the user never saw;
    # they may SET a first password without providing the current one.
    has_password: bool = Field(default=True)
    # "Casa" del usuario — la usan classes/tournaments para distancias.
    home_lat: float | None = Field(default=None)
    home_lon: float | None = Field(default=None)
    created_at: datetime
