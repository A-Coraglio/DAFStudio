from fastapi import APIRouter, Depends, Query
from apps.courts.service.dto import (
    CourtOutputDTO,
    CreatePrivateCourtInputDTO,
    UpdatePrivateCourtInputDTO,
)
from apps.courts.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/courts/", responses={
    200: {
        "model": list[CourtOutputDTO],
        "description": "List of courts (club courts + own private courts)"
    },
    401: {"description": "Unauthorized"}
})
async def list_courts(
    sport_id: int | None = Query(default=None, description="Filter by sport"),
    club_id: int | None = Query(default=None, description="Filter by club"),
    near_lat: float | None = Query(default=None, description="Origin latitude for proximity filter"),
    near_lon: float | None = Query(default=None, description="Origin longitude for proximity filter"),
    radius_km: float | None = Query(default=None, description="Max distance in km (requires near_lat + near_lon)"),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().courts_lister(
        current_user_id=current_user_id,
        sport_id=sport_id,
        club_id=club_id,
        near_lat=near_lat,
        near_lon=near_lon,
        radius_km=radius_km,
    )


@router.get("/courts/{court_id}/", responses={
    200: {"model": CourtOutputDTO, "description": "Court instance"},
    401: {"description": "Unauthorized"},
    404: {"description": "Court not found or not visible"},
})
async def get_court(
    court_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().courts_getter(
        court_id=court_id, current_user_id=current_user_id
    )


@router.post("/courts/", responses={
    200: {"model": CourtOutputDTO, "description": "Created private court"},
    401: {"description": "Unauthorized"},
})
async def create_private_court(
    body: CreatePrivateCourtInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    """Creates a private court owned by the current user (e.g. backyard court).
    Club courts are created through a different (future) admin flow."""
    return await AppService().courts_creator_private(
        data=body, owner_id=current_user_id
    )


@router.put("/courts/{court_id}/", responses={
    200: {"model": CourtOutputDTO, "description": "Updated private court"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not the owner of the court"},
    404: {"description": "Court not found"},
})
async def update_private_court(
    court_id: int,
    body: UpdatePrivateCourtInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().courts_updater_private(
        court_id=court_id, data=body, current_user_id=current_user_id
    )


@router.delete("/courts/{court_id}/", responses={
    200: {"description": "Deleted court id"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not the owner of the court"},
    404: {"description": "Court not found"},
})
async def delete_private_court(
    court_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    deleted_id = await AppService().courts_deleter_private(
        court_id=court_id, current_user_id=current_user_id
    )
    return {"deleted_id": deleted_id}
