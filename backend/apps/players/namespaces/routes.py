from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from apps.players.service.dto import PlayerOutputDTO, UpdatePlayerInputDTO
from apps.players.service.appservice import AppService, MAX_AVATAR_BYTES
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


@router.post("/players/me/avatar/", responses={
    200: {"model": PlayerOutputDTO, "description": "Avatar updated"},
    400: {"description": "Invalid file (extension or size)"},
    401: {"description": "Unauthorized"},
})
async def upload_my_avatar(
    file: UploadFile = File(...),
    current_user_id: int = Depends(get_current_user_id),
):
    # Enforce size cheaply from the Content-Length-ish `size` hint where
    # available; fall back to reading into memory would lose the stream.
    # UploadFile's `size` is set by Starlette when the upload is buffered.
    if file.size is not None and file.size > MAX_AVATAR_BYTES:
        raise HTTPException(status_code=400, detail="Avatar too large (2MB max)")
    try:
        return await AppService().set_avatar_for_user(
            user_id=current_user_id,
            filename=file.filename or "upload.png",
            file_obj=file.file,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


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
