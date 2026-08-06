from datetime import datetime

from pydantic import BaseModel, Field


class AdminUserDDO(BaseModel):
    """Fila del listado de usuarios del panel admin: cuenta + nombre visible
    + flags de estado."""

    user_id: int
    username: str
    email: str
    display_name: str = Field(description="Nombre del player o username")
    is_admin: bool = False
    banned_at: datetime | None = None
    deleted_at: datetime | None = None
    created_at: datetime


class AuditEntryDDO(BaseModel):
    id: int
    admin_user_id: int
    admin_username: str
    action: str
    target_type: str
    target_id: int
    detail: str | None = None
    created_at: datetime
