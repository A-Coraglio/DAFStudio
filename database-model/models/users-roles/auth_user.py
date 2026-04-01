from sqlmodel import SQLModel, Field
from datetime import datetime, timezone

class AuthUser(SQLModel, table=True):
    __tablename__ = "auth_user" # type: ignore
    id: int = Field(primary_key=True, index=True)
    username: str = Field(max_length=50, unique=True)
    email: str = Field(unique=True)
    password_hash: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))