from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from apps.players.service.dto import (
    MyGameOutputDTO,
    PlayerOutputDTO,
    PlayerStatsOutputDTO,
    UpdatePlayerInputDTO,
)
from apps.players.service.appservice import AppService, MAX_AVATAR_BYTES
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/players/", responses={
    200: {"model": list[PlayerOutputDTO], "description": "Players matching the filters, ordered by ranking"},
    401: {"description": "Unauthorized"},
})
async def search_players(
    query: str | None = Query(default=None, description="Substring on first or last name"),
    sport_id: int | None = Query(default=None, description="Filter by favorite sport"),
    level: str | None = Query(default=None, description="beginner / intermediate / advanced"),
    limit: int = Query(default=30, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    current_user_id: int = Depends(get_current_user_id),
):
    """Discovery endpoint. Excludes the caller from results (it's the social
    feed, you don't want to find yourself)."""
    return await AppService().players_search(
        query=query,
        sport_id=sport_id,
        level=level,
        exclude_user_id=current_user_id,
        limit=limit,
        offset=offset,
    )


@router.get("/players/me/", responses={
    200: {"model": PlayerOutputDTO, "description": "Current user's player profile"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player profile not found"},
})
async def get_my_player(current_user_id: int = Depends(get_current_user_id)):
    return await AppService().players_getter_by_user_id(user_id=current_user_id)


@router.get("/players/me/games/", responses={
    200: {"model": list[MyGameOutputDTO], "description": "Games the current user participated in, with outcome + team side"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player profile not found"},
})
async def my_games(
    status: str | None = Query(default=None, description="open / full / finished / cancelled"),
    mode: str | None = Query(default=None, description="casual / competitive"),
    limit: int = Query(default=30, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().my_games(
        user_id=current_user_id,
        status=status,
        mode=mode,
        limit=limit,
        offset=offset,
    )


@router.get("/players/me/stats/", responses={
    200: {"model": PlayerStatsOutputDTO, "description": "Aggregate W/L/D + current ranking for the caller"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player profile not found"},
})
async def my_stats(current_user_id: int = Depends(get_current_user_id)):
    return await AppService().my_stats(user_id=current_user_id)


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


@router.get("/players/{player_id}/stats/", responses={
    200: {"model": PlayerStatsOutputDTO, "description": "Public W/L/D stats"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player not found"},
})
async def player_stats(
    player_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().player_stats(player_id=player_id)


@router.get("/players/{player_id}/games/", responses={
    200: {"model": list[MyGameOutputDTO], "description": "Recent games"},
    401: {"description": "Unauthorized"},
    404: {"description": "Player not found"},
})
async def player_games(
    player_id: int,
    limit: int = Query(default=10, le=30),
    offset: int = Query(default=0),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().player_games(
        player_id=player_id, limit=limit, offset=offset,
    )
