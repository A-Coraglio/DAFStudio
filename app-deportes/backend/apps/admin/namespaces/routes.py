from fastapi import APIRouter, Depends, Query

from apps.admin.service.appservice import AppService
from apps.admin.service.auth_dependency import require_admin
from apps.admin.service.dto import (
    AdminUserOutputDTO,
    AuditEntryOutputDTO,
    KickPlayerInputDTO,
    LogsOutputDTO,
)
from apps.teachers.service.dto import TeacherRequestOutputDTO

# Todas las rutas exigen fila en la tabla `admin` (403 si no).
router: APIRouter = APIRouter(prefix="/api/admin")


@router.get("/users/", responses={
    200: {"model": list[AdminUserOutputDTO], "description": "Cuentas (incluye baneadas y eliminadas)"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not an admin"},
})
async def list_users(
    query: str | None = Query(default=None, description="username/email/nombre"),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    admin_user_id: int = Depends(require_admin),
):
    return await AppService().users_lister(
        query=query, limit=limit, offset=offset
    )


@router.post("/users/{user_id}/ban/", responses={
    200: {"description": "Usuario baneado"},
    400: {"description": "Auto-ban o target admin"},
    403: {"description": "Not an admin"},
    404: {"description": "Cuenta inexistente o eliminada"},
})
async def ban_user(
    user_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().user_banner(
        admin_user_id=admin_user_id, target_user_id=user_id, banned=True
    )
    return {"ok": True}


@router.post("/users/{user_id}/unban/", responses={
    200: {"description": "Ban levantado"},
    403: {"description": "Not an admin"},
    404: {"description": "Cuenta inexistente o eliminada"},
})
async def unban_user(
    user_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().user_banner(
        admin_user_id=admin_user_id, target_user_id=user_id, banned=False
    )
    return {"ok": True}


@router.delete("/users/{user_id}/", responses={
    200: {"description": "Cuenta soft-borrada y anonimizada"},
    400: {"description": "Auto-borrado o target admin"},
    403: {"description": "Not an admin"},
    404: {"description": "Cuenta inexistente"},
})
async def delete_user(
    user_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().user_deleter(
        admin_user_id=admin_user_id, target_user_id=user_id
    )
    return {"ok": True}


@router.post("/users/{user_id}/promote/", responses={
    200: {"description": "Usuario promovido a admin"},
    403: {"description": "Not an admin"},
    404: {"description": "Cuenta inexistente"},
})
async def promote_user(
    user_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().user_promoter(
        admin_user_id=admin_user_id, target_user_id=user_id, promote=True
    )
    return {"ok": True}


@router.post("/users/{user_id}/demote/", responses={
    200: {"description": "Rol admin quitado"},
    400: {"description": "Último admin"},
    403: {"description": "Not an admin"},
})
async def demote_user(
    user_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().user_promoter(
        admin_user_id=admin_user_id, target_user_id=user_id, promote=False
    )
    return {"ok": True}


@router.post("/games/{game_id}/cancel/", responses={
    200: {"description": "Partido cancelado por admin"},
    400: {"description": "Partido ya terminado/cancelado"},
    403: {"description": "Not an admin"},
    404: {"description": "Partido inexistente"},
})
async def cancel_game(
    game_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().game_canceller(
        admin_user_id=admin_user_id, game_id=game_id
    )
    return {"ok": True}


@router.post("/games/{game_id}/kick/", responses={
    200: {"description": "Jugador sacado del partido"},
    400: {"description": "Partido cerrado a cambios"},
    403: {"description": "Not an admin"},
    404: {"description": "Partido o jugador inexistente"},
})
async def kick_player(
    game_id: int,
    body: KickPlayerInputDTO,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().player_kicker(
        admin_user_id=admin_user_id,
        game_id=game_id,
        player_id=body.player_id,
    )
    return {"ok": True}


@router.get("/teacher-requests/", responses={
    200: {"model": list[TeacherRequestOutputDTO], "description": "Solicitudes de profe pendientes"},
    403: {"description": "Not an admin"},
})
async def list_teacher_requests(
    admin_user_id: int = Depends(require_admin),
):
    return await AppService().teacher_requests_lister()


@router.post("/teacher-requests/{request_id}/approve/", responses={
    200: {"description": "Solicitud aprobada: el usuario ya es profe"},
    403: {"description": "Not an admin"},
    404: {"description": "Solicitud inexistente"},
    409: {"description": "Ya estaba resuelta"},
})
async def approve_teacher_request(
    request_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().teacher_request_resolver(
        admin_user_id=admin_user_id, request_id=request_id, approve=True
    )
    return {"ok": True}


@router.post("/teacher-requests/{request_id}/reject/", responses={
    200: {"description": "Solicitud rechazada"},
    403: {"description": "Not an admin"},
    404: {"description": "Solicitud inexistente"},
    409: {"description": "Ya estaba resuelta"},
})
async def reject_teacher_request(
    request_id: int,
    admin_user_id: int = Depends(require_admin),
):
    await AppService().teacher_request_resolver(
        admin_user_id=admin_user_id, request_id=request_id, approve=False
    )
    return {"ok": True}


@router.get("/audit/", responses={
    200: {"model": list[AuditEntryOutputDTO], "description": "Acciones admin, más recientes primero"},
    403: {"description": "Not an admin"},
})
async def list_audit(
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
    admin_user_id: int = Depends(require_admin),
):
    return await AppService().audit_lister(limit=limit, offset=offset)


@router.get("/logs/", responses={
    200: {"model": LogsOutputDTO, "description": "Últimas líneas del log del server"},
    403: {"description": "Not an admin"},
})
async def read_logs(
    lines: int = Query(default=200, ge=10, le=1000),
    admin_user_id: int = Depends(require_admin),
):
    return AppService().logs_reader(lines=lines)
