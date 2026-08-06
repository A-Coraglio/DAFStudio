from fastapi import APIRouter, Depends

from apps.sport_modes.service.appservice import AppService
from apps.sport_modes.service.dto import SportModeOutputDTO
from apps.users.service.auth_dependency import get_current_user_id


router: APIRouter = APIRouter(prefix="/api")


@router.get(
    "/sport-modes/",
    responses={
        200: {
            "model": list[SportModeOutputDTO],
            "description": "List of sport modes, optionally filtered by sport_id",
        },
        401: {"description": "Unauthorized"},
    },
)
async def list_sport_modes(
    sport_id: int | None = None,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().list_modes(sport_id=sport_id)


@router.get(
    "/sport-modes/{mode_id}/",
    responses={
        200: {"model": SportModeOutputDTO, "description": "Sport mode"},
        404: {"description": "Sport mode not found"},
        401: {"description": "Unauthorized"},
    },
)
async def get_sport_mode(
    mode_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().get_mode(mode_id=mode_id)
# NOTE: the POST route was removed on purpose (2026-07-20) — sport modes are
# a seeded catalog with no consumer; any authenticated user being able to
# create rows was a leftover. Re-add behind an admin role if it's ever needed.
