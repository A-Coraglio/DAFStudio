from pydantic import BaseModel

class RegisterInputDTO(BaseModel):
    username: str
    email: str
    password: str

class LoginInputDTO(BaseModel):
    email: str
    password: str

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
