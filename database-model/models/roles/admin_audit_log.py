from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func


class AdminAuditLog(SQLModel, table=True):
    """Auditoría de acciones de administración: quién hizo qué sobre quién.
    Solo se escribe desde la app admin del backend."""

    __tablename__ = "admin_audit_log"  # type: ignore
    id: int = Field(primary_key=True)
    admin_user_id: int = Field(foreign_key="auth_user.id")
    # ban / unban / delete_user / promote / demote / cancel_game / kick_player
    action: str = Field(max_length=30)
    # "user" | "game" — sobre qué tipo de recurso actuó.
    target_type: str = Field(max_length=10)
    target_id: int
    detail: str | None = Field(max_length=255, default=None)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
