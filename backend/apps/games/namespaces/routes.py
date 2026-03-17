
from fastapi import APIRouter, Request
from apps.games.service.dto import GamesOutputDTO
from apps.games.service.appservice import AppService

router : APIRouter = APIRouter(prefix="/api")


#example route
@router.get("/games/",responses={
        200: {
            "model": GamesOutputDTO,
            "description": "list of games"
        }
    })
async def list_games():

    games_list : list[GamesOutputDTO] = await AppService().games_lister()
    return games_list

@router.get("/games/{game_id}/",responses={
        200: {
            "model": GamesOutputDTO, #TODO change
            "description": "game instance"
        }
    })
async def get_games():

    game : GamesOutputDTO = await AppService().games_getter() #TODO create
    return game

@router.post("/games/",responses={
        200: {
            "model": GamesOutputDTO, #TODO change
            "description": "game instance"
        }
    })
async def create_games():

    game : GamesOutputDTO = await AppService().games_creator() #TODO create
    return game

@router.put("/games/{games_id}/",responses={
        200: {
            "model": GamesOutputDTO, #TODO change
            "description": "game instance"
        }
    })
async def update_games():

    game : GamesOutputDTO = await AppService().games_updater() #TODO create
    return game

@router.delete("/games/{games_id}/",responses={
        200: {
            "model": GamesOutputDTO, #TODO change
            "description": "id of the deleted instance"
        }
    })
async def delete_game():

    game : GamesOutputDTO = await AppService().games_deleter() #TODO create
    return game
