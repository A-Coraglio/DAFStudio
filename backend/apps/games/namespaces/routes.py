from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from apps.games.service.dto import GamesOutputDTO
from apps.games.service.appservice import AppService

router : APIRouter = APIRouter(prefix="/api")

class GameCreateSchema(BaseModel):
    name: str

class GameUpdateSchema(BaseModel):
    name: str


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
            "model": GamesOutputDTO, 
            "description": "game instance"},
        404: {
            "description": "game not found"
        }
    })
async def get_games(game_id: int):

    game : GamesOutputDTO = await AppService().games_getter(game_id=game_id)
    return game

@router.post("/games/",responses={
        200: {
            "model": GamesOutputDTO,
            "description": "Created game instance"
        }
    })
async def create_games(body: GameCreateSchema):

    game : GamesOutputDTO = await AppService().games_creator(name=body.name)
    return game

@router.put("/games/{games_id}/",responses={
        200: {
            "model": GamesOutputDTO,
            "description": "Updated game instance"},
        404: {"Description": "game not found"}
        }
    )
async def update_games(game_id: int, body: GameUpdateSchema):

    game : GamesOutputDTO  = await AppService().games_updater(game_id=game_id, name=body.name)
    return game

@router.delete("/games/{games_id}/",responses={
        200: {
            "model": dict,
            "description": "id of the deleted instance"},
        404: {"Description": "game not found"}
        }
    )
async def delete_game(game_id: int):
    deleted_id : int  = await AppService().games_deleter(game_id=game_id)
    return {"deleted_id": deleted_id}
