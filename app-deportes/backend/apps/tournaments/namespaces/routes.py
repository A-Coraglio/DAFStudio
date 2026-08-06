from fastapi import APIRouter, Depends, Query

from apps.tournaments.service.dto import (
    TournamentOutputDTO,
    TournamentParticipantOutputDTO,
)
from apps.tournaments.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/tournaments/", responses={
    200: {"model": list[TournamentOutputDTO], "description": "List of tournaments"},
    401: {"description": "Unauthorized"},
})
async def list_tournaments(
    sport_id: int | None = Query(default=None, description="Filter by sport"),
    level: str | None = Query(default=None, description="Filter by target level"),
    status: str | None = Query(default=None, description="Filter by status"),
    near_lat: float | None = Query(default=None, description="Origin latitude"),
    near_lon: float | None = Query(default=None, description="Origin longitude"),
    radius_km: float | None = Query(default=None, description="Max distance in km"),
    limit: int = Query(default=30, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().tournaments_lister(
        sport_id=sport_id,
        level=level,
        status=status,
        near_lat=near_lat,
        near_lon=near_lon,
        radius_km=radius_km,
        limit=limit,
        offset=offset,
    )


# Declared before the /{tournament_id}/ route so "recommended" is never parsed
# as an id.
@router.get("/tournaments/recommended/", responses={
    200: {
        "model": list[TournamentOutputDTO],
        "description": "Tournaments picked for the user by sport, level and distance",
    },
    401: {"description": "Unauthorized"},
})
async def recommended_tournaments(
    near_lat: float | None = Query(default=None, description="Origin latitude"),
    near_lon: float | None = Query(default=None, description="Origin longitude"),
    sport_id: int | None = Query(
        default=None, description="Hard-filter to this sport (home selector)"
    ),
    limit: int = Query(default=8, ge=1, le=30),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().tournaments_recommended(
        current_user_id=current_user_id,
        near_lat=near_lat,
        near_lon=near_lon,
        limit=limit,
        sport_id=sport_id,
    )


@router.get("/tournaments/{tournament_id}/", responses={
    200: {"model": TournamentOutputDTO, "description": "Tournament instance"},
    401: {"description": "Unauthorized"},
    404: {"description": "Tournament not found"},
})
async def get_tournament(
    tournament_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().tournaments_getter(tournament_id=tournament_id)


@router.get("/tournaments/{tournament_id}/participants/", responses={
    200: {
        "model": list[TournamentParticipantOutputDTO],
        "description": "Players enrolled in the tournament, join order",
    },
    401: {"description": "Unauthorized"},
    404: {"description": "Tournament not found"},
})
async def list_tournament_participants(
    tournament_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().tournament_participants_lister(
        tournament_id=tournament_id
    )


@router.post("/tournaments/{tournament_id}/join/", responses={
    200: {"model": TournamentOutputDTO, "description": "Updated tournament after enrolling"},
    401: {"description": "Unauthorized"},
    404: {"description": "Tournament or player not found"},
    409: {"description": "Registration closed, tournament full, or already enrolled"},
})
async def join_tournament(
    tournament_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().tournament_joiner(
        tournament_id=tournament_id, current_user_id=current_user_id
    )


@router.post("/tournaments/{tournament_id}/leave/", responses={
    200: {"model": TournamentOutputDTO, "description": "Updated tournament after unenrolling"},
    401: {"description": "Unauthorized"},
    404: {"description": "Tournament or player not found"},
    409: {"description": "Tournament already started, or user not enrolled"},
})
async def leave_tournament(
    tournament_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().tournament_leaver(
        tournament_id=tournament_id, current_user_id=current_user_id
    )
