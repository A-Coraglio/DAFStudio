from fastapi import APIRouter, Depends
from apps.sports.service.dto import SportOutputDTO
from apps.sports.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.get("/sports/", responses={
    200: {
        "model": list[SportOutputDTO],
        "description": "List of sports"
    },
    401: {
        "description": "Unauthorized"
    }
})
async def list_sports(current_user_id: int = Depends(get_current_user_id)):
    return await AppService().sports_lister()


@router.get("/sports/{sport_id}/", responses={
    200: {
        "model": SportOutputDTO,
        "description": "Sport instance"
    },
    401: {
        "description": "Unauthorized"
    },
    404: {
        "description": "Sport not found"
    }
})
async def get_sport(
    sport_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().sports_getter(sport_id=sport_id)
