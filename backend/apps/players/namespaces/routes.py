from fastapi import APIRouter, Depends
from apps.players.service.dto import PlayerOutputDTO, UpdatePlayerInputDTO
from apps.players.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/players/me/", responses={
    200: {"model": PlayerOutputDTO, "description": "Current user's player profile"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player profile not found"},
})
async def get_my_player(current_user_id: int = Depends(get_current_user_id)):
    return await AppService().players_getter_by_user_id(user_id=current_user_id)


@router.put("/players/me/", responses={
    200: {"model": PlayerOutputDTO, "description": "Updated player profile"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player profile not found"},
})
async def update_my_player(
    body: UpdatePlayerInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().players_updater_by_user_id(
        user_id=current_user_id, data=body
    )


@router.get("/players/{player_id}/", responses={
    200: {"model": PlayerOutputDTO, "description": "Public player profile"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player not found"},
})
async def get_player(
    player_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().players_getter_by_id(player_id=player_id)
