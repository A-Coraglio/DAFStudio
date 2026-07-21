from datetime import datetime

from pydantic import BaseModel, Field


class TeacherApplyInputDTO(BaseModel):
    bio: str = Field(description="Presentación que ven los alumnos")
    price_per_hour: float = Field(gt=0)
    experience_years: int | None = Field(default=None, ge=0, le=80)
    sport_ids: list[int] = Field(description="Deportes que enseña (≥1)")


class UpdateTeacherInputDTO(BaseModel):
    bio: str | None = None
    price_per_hour: float | None = Field(default=None, gt=0)
    experience_years: int | None = Field(default=None, ge=0, le=80)
    sport_ids: list[int] | None = None


class MyTeacherOutputDTO(BaseModel):
    id: int
    user_id: int
    bio: str | None = None
    price_per_hour: float
    experience_years: int | None = None
    sport_ids: list[int] = Field(default_factory=list)


class TeacherRequestOutputDTO(BaseModel):
    id: int
    user_id: int
    bio: str
    price_per_hour: float
    experience_years: int | None = None
    sport_ids: list[int] = Field(default_factory=list)
    status: str
    created_at: datetime
    display_name: str | None = None
    username: str | None = None


class TeacherStatusOutputDTO(BaseModel):
    """Todo lo que la UI necesita para decidir qué mostrar en el perfil:
    ¿ya sos profe? ¿tenés solicitud pendiente/rechazada?"""

    is_teacher: bool = False
    teacher: MyTeacherOutputDTO | None = None
    request: TeacherRequestOutputDTO | None = None
