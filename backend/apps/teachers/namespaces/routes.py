from fastapi import APIRouter, Depends

from apps.teachers.service.appservice import AppService
from apps.teachers.service.dto import (
    MyTeacherOutputDTO,
    TeacherApplyInputDTO,
    TeacherStatusOutputDTO,
    UpdateTeacherInputDTO,
)
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/teachers/my-status/", responses={
    200: {"model": TeacherStatusOutputDTO, "description": "Si sos profe y el estado de tu solicitud"},
    401: {"description": "Unauthorized"},
})
async def my_status(
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().status_getter(user_id=current_user_id)


@router.post("/teachers/apply/", responses={
    200: {"model": TeacherStatusOutputDTO, "description": "Solicitud creada (queda pendiente de un admin)"},
    400: {"description": "Datos inválidos"},
    401: {"description": "Unauthorized"},
    409: {"description": "Ya sos profe o ya tenés solicitud pendiente"},
})
async def apply(
    body: TeacherApplyInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().applier(user_id=current_user_id, data=body)


@router.put("/teachers/me/", responses={
    200: {"model": MyTeacherOutputDTO, "description": "Perfil de profe actualizado"},
    400: {"description": "Datos inválidos"},
    401: {"description": "Unauthorized"},
    404: {"description": "No sos profesor"},
})
async def update_me(
    body: UpdateTeacherInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().me_updater(user_id=current_user_id, data=body)
