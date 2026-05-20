from pydantic import BaseModel

class RegisterInputDTO(BaseModel):
    username: str
    email: str
    password: str

class LoginInputDTO(BaseModel):
    email: str
    password: str

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
