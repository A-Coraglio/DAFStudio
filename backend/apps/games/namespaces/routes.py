
from fastapi import APIRouter
from apps.games.service.dto import UserOutputDTO
from apps.games.service.appservice import AppService

router : APIRouter = APIRouter(prefix="/api")


#example route
@router.get("/get-users/",responses={
        200: {
            "model": UserOutputDTO,
            "description": "list of games"
        }
    })
async def list_users():

    user_list : list[UserOutputDTO] = await AppService().user_lister()
    return user_list
    