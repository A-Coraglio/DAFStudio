from datetime import datetime

from fastapi import APIRouter, Depends, Query

from apps.games.service.dto import (
    GamesOutputDTO,
    GameCreateInputDTO,
    GameUpdateInputDTO,
    GamePlayerOutputDTO,
    JoinGameInputDTO,
    ReportResultInputDTO,
)
from apps.games.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/games/", responses={
    200: {"model": list[GamesOutputDTO], "description": "List of games"},
    401: {"description": "Unauthorized"},
})
async def list_games(
    sport_id: int | None = Query(default=None),
    mode: str | None = Query(default=None, description="casual / competitive / matchmaking"),
    level: str | None = Query(default=None),
    status: str | None = Query(default=None),
    organizer_id: int | None = Query(default=None),
    scheduled_after: datetime | None = Query(default=None),
    scheduled_before: datetime | None = Query(default=None),
    near_lat: float | None = Query(default=None),
    near_lon: float | None = Query(default=None),
    radius_km: float | None = Query(default=None),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().games_lister(
        sport_id=sport_id,
        mode=mode,
        level=level,
        status=status,
        organizer_id=organizer_id,
        scheduled_after=scheduled_after,
        scheduled_before=scheduled_before,
        near_lat=near_lat,
        near_lon=near_lon,
        radius_km=radius_km,
    )


@router.get("/games/{game_id}/", responses={
    200: {"model": GamesOutputDTO, "description": "Game instance"},
    401: {"description": "Unauthorized"},
    404: {"description": "Game not found"},
})
async def get_game(
    game_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().games_getter(game_id=game_id)


@router.post("/games/", responses={
    200: {"model": GamesOutputDTO, "description": "Created game"},
    401: {"description": "Unauthorized"},
})
async def create_game(
    body: GameCreateInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().games_creator(data=body, organizer_id=current_user_id)


@router.put("/games/{game_id}/", responses={
    200: {"model": GamesOutputDTO, "description": "Updated game"},
    401: {"description": "Unauthorized"},
    403: {"description": "Only the organizer can update this game"},
    404: {"description": "Game not found"},
})
async def update_game(
    game_id: int,
    body: GameUpdateInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().games_updater(
        game_id=game_id, data=body, current_user_id=current_user_id
    )


@router.delete("/games/{game_id}/", responses={
    200: {"description": "Deleted game id"},
    401: {"description": "Unauthorized"},
    403: {"description": "Only the organizer can delete this game"},
    404: {"description": "Game not found"},
})
async def delete_game(
    game_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    deleted_id = await AppService().games_deleter(
        game_id=game_id, current_user_id=current_user_id
    )
    return {"deleted_id": deleted_id}


# -------- Participants --------

@router.get("/games/{game_id}/players/", responses={
    200: {"model": list[GamePlayerOutputDTO], "description": "Players in the game (enriched with name + ranking)"},
    401: {"description": "Unauthorized"},
})
async def list_game_players(
    game_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().game_players_lister(game_id=game_id)


@router.post("/games/{game_id}/join/", responses={
    200: {"model": GamesOutputDTO, "description": "Updated game after joining"},
    401: {"description": "Unauthorized"},
    404: {"description": "Game or player not found"},
    409: {"description": "Game is not open, is full, or user already in"},
})
async def join_game(
    game_id: int,
    body: JoinGameInputDTO = JoinGameInputDTO(),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().game_join(
        game_id=game_id,
        current_user_id=current_user_id,
        team_id=body.team_id,
    )


@router.post("/games/{game_id}/leave/", responses={
    200: {"model": GamesOutputDTO, "description": "Updated game after leaving"},
    401: {"description": "Unauthorized"},
    404: {"description": "Game or player not found"},
    409: {"description": "Game has finished or user not in it"},
})
async def leave_game(
    game_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().game_leave(
        game_id=game_id, current_user_id=current_user_id
    )


@router.post("/games/{game_id}/report-result/", responses={
    200: {"model": GamesOutputDTO, "description": "Confirmation stored; game is finalized if all participants agree"},
    401: {"description": "Unauthorized"},
    404: {"description": "Game or player not found"},
    409: {"description": "Game already finished, or user is not a participant"},
})
async def report_result(
    game_id: int,
    body: ReportResultInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().game_report_result(
        game_id=game_id,
        current_user_id=current_user_id,
        reported_home=body.reported_home,
        reported_away=body.reported_away,
    )
