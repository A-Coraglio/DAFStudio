from fastapi import APIRouter, Depends, Query
from apps.clubs.service.dto import (
    ClubOutputDTO,
    CreateClubInputDTO,
    UpdateClubInputDTO,
)
from apps.clubs.service.appservice import AppService
from apps.courts.service.dto import (
    CourtOutputDTO,
    CreatePrivateCourtInputDTO,
)
from apps.admin.service.auth_dependency import require_admin
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


# -------- Clubs CRUD --------

@router.get("/clubs/", responses={
    200: {"model": list[ClubOutputDTO], "description": "List of clubs"},
    401: {"description": "Unauthorized"},
})
async def list_clubs(
    city: str | None = Query(default=None, description="Filter by city (case-insensitive)"),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().clubs_lister(city=city)


# Antes de /{club_id}/ para que "mine" no se parsee como id.
@router.get("/clubs/mine/", responses={
    200: {"model": list[ClubOutputDTO], "description": "Clubes de los que sos dueño"},
    401: {"description": "Unauthorized"},
})
async def my_clubs(
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().my_clubs_lister(owner_id=current_user_id)


@router.get("/clubs/{club_id}/", responses={
    200: {"model": ClubOutputDTO, "description": "Club instance"},
    401: {"description": "Unauthorized"},
    404: {"description": "Club not found"},
})
async def get_club(
    club_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().clubs_getter(club_id=club_id)


@router.post("/clubs/", responses={
    200: {"model": ClubOutputDTO, "description": "Created club (admin only)"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not an admin"},
    404: {"description": "Owner user not found"},
})
async def create_club(
    body: CreateClubInputDTO,
    admin_user_id: int = Depends(require_admin),
):
    return await AppService().clubs_creator_admin(
        data=body, admin_user_id=admin_user_id
    )


@router.put("/clubs/{club_id}/", responses={
    200: {"model": ClubOutputDTO, "description": "Updated club"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not the owner of the club"},
    404: {"description": "Club not found"},
})
async def update_club(
    club_id: int,
    body: UpdateClubInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().clubs_updater(
        club_id=club_id, data=body, current_user_id=current_user_id
    )


@router.delete("/clubs/{club_id}/", responses={
    200: {"description": "Deleted club id"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not the owner of the club"},
    404: {"description": "Club not found"},
})
async def delete_club(
    club_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    deleted_id = await AppService().clubs_deleter(
        club_id=club_id, current_user_id=current_user_id
    )
    return {"deleted_id": deleted_id}


# -------- Nested courts under a club --------

@router.get("/clubs/{club_id}/courts/", responses={
    200: {"model": list[CourtOutputDTO], "description": "Courts of this club"},
    401: {"description": "Unauthorized"},
    404: {"description": "Club not found"},
})
async def list_club_courts(
    club_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().clubs_list_courts(
        club_id=club_id, current_user_id=current_user_id
    )


@router.post("/clubs/{club_id}/courts/", responses={
    200: {"model": CourtOutputDTO, "description": "Created club court"},
    401: {"description": "Unauthorized"},
    403: {"description": "Only the club owner can add courts"},
    404: {"description": "Club not found"},
})
async def create_club_court(
    club_id: int,
    body: CreatePrivateCourtInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().clubs_create_court(
        club_id=club_id, data=body, current_user_id=current_user_id
    )
