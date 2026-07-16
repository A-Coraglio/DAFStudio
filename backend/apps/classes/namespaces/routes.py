from fastapi import APIRouter, Depends, Query

from apps.classes.service.dto import ClassOutputDTO
from apps.classes.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/classes/", responses={
    200: {"model": list[ClassOutputDTO], "description": "List of teachers / classes"},
    401: {"description": "Unauthorized"},
})
async def list_classes(
    sport_id: int | None = Query(default=None, description="Filter by sport taught"),
    max_price: float | None = Query(default=None, description="Max price per hour"),
    near_lat: float | None = Query(default=None, description="Origin latitude"),
    near_lon: float | None = Query(default=None, description="Origin longitude"),
    radius_km: float | None = Query(default=None, description="Max distance in km"),
    limit: int = Query(default=30, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().classes_lister(
        sport_id=sport_id,
        max_price=max_price,
        near_lat=near_lat,
        near_lon=near_lon,
        radius_km=radius_km,
        limit=limit,
        offset=offset,
    )


# Before /{teacher_id}/ so "recommended" isn't parsed as an id.
@router.get("/classes/recommended/", responses={
    200: {
        "model": list[ClassOutputDTO],
        "description": "Classes picked for the user by sport and distance",
    },
    401: {"description": "Unauthorized"},
})
async def recommended_classes(
    near_lat: float | None = Query(default=None, description="Origin latitude"),
    near_lon: float | None = Query(default=None, description="Origin longitude"),
    limit: int = Query(default=8, ge=1, le=30),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().classes_recommended(
        current_user_id=current_user_id,
        near_lat=near_lat,
        near_lon=near_lon,
        limit=limit,
    )


@router.get("/classes/{teacher_id}/", responses={
    200: {"model": ClassOutputDTO, "description": "Class (teacher) instance"},
    401: {"description": "Unauthorized"},
    404: {"description": "Class not found"},
})
async def get_class(
    teacher_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().classes_getter(teacher_id=teacher_id)
