from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func
from datetime import datetime, timezone

class AuthUser(SQLModel, table=True):
    __tablename__ = "auth_user" # type: ignore
    id: int = Field(primary_key=True, index=True)
    username: str = Field(max_length=50, unique=True)
    email: str = Field(unique=True)
    password_hash: str
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
    # Default location for feed / matchmaking. Frontend may override with current GPS.
    home_lat: float | None = Field(default=None)
    home_lon: float | None = Field(default=None)
