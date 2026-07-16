from pydantic import BaseModel, Field

class RegisterInputDTO(BaseModel):
    username: str
    email: str
    password: str

class LoginInputDTO(BaseModel):
    # Either the email or the username works. `email` is kept as a legacy
    # alias so older clients keep logging in.
    identifier: str | None = Field(default=None, description="Email or username")
    email: str | None = Field(default=None, description="Legacy alias for identifier")
    password: str

    @property
    def login_id(self) -> str:
        return (self.identifier or self.email or "").strip()

class GoogleLoginInputDTO(BaseModel):
    """The Flutter client signs in with Google natively, gets back an id_token,
    and sends it here. The backend validates it against Google and emits its
    own JWT — Google is just the source of identity, not a session manager."""
    id_token: str

class UpdateUserInputDTO(BaseModel):
    username: str | None = None
    email: str | None = None
    password: str | None = None

class UserOutputDTO(BaseModel):
    id: int
    username: str
    email: str

class TokenOutputDTO(BaseModel):
    access_token: str
    token_type: str = "bearer"
