from datetime import datetime

from pydantic import BaseModel, Field


class AdminUserOutputDTO(BaseModel):
    user_id: int
    username: str
    email: str
    display_name: str
    is_admin: bool = False
    banned_at: datetime | None = None
    deleted_at: datetime | None = None
    created_at: datetime


class AuditEntryOutputDTO(BaseModel):
    id: int
    admin_user_id: int
    admin_username: str
    action: str = Field(
        description="ban / unban / delete_user / promote / demote / "
        "cancel_game / kick_player"
    )
    target_type: str
    target_id: int
    detail: str | None = None
    created_at: datetime


class KickPlayerInputDTO(BaseModel):
    player_id: int = Field(description="Player a sacar del partido")


class LogsOutputDTO(BaseModel):
    lines: list[str] = Field(description="Últimas líneas del log del server")
