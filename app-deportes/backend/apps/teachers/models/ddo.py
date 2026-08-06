from datetime import datetime

from pydantic import BaseModel, Field


class TeacherRequestDDO(BaseModel):
    id: int
    user_id: int
    bio: str
    price_per_hour: float
    experience_years: int | None = None
    sport_ids: list[int] = Field(default_factory=list)
    status: str = Field(description="pending / approved / rejected")
    created_at: datetime
    # Solo en el listado del panel admin (join a auth_user/player).
    display_name: str | None = None
    username: str | None = None


class MyTeacherDDO(BaseModel):
    """El perfil de profe del usuario logueado (tabla teacher + sports)."""

    id: int = Field(description="teacher id")
    user_id: int
    bio: str | None = None
    price_per_hour: float
    experience_years: int | None = None
    sport_ids: list[int] = Field(default_factory=list)
