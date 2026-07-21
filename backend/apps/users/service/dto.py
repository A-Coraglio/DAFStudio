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
    # Required whenever `password` is sent: changing the password proves you
    # know the current one (a stolen 60-min token must not take the account).
    current_password: str | None = None

class UserOutputDTO(BaseModel):
    id: int
    username: str
    email: str
    # False → cuenta creada con Google que todavía no seteó contraseña propia;
    # el frontend puede ofrecer "Crear contraseña" en vez de "Cambiar".
    has_password: bool = True

class RefreshInputDTO(BaseModel):
    refresh_token: str


class TokenOutputDTO(BaseModel):
    access_token: str
    # Long-lived (30 días), rotado en cada refresh. Solo sirve contra
    # POST /api/auth/refresh/ — los endpoints normales lo rechazan.
    refresh_token: str | None = None
    token_type: str = "bearer"
