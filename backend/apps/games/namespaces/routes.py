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

    game : GamesOutputDTO | None = await AppService().games_getter(game_id=game_id)
    if game is None:
        raise HTTPException(status_code=404, detail="Game not found")
    return game

@router.post("/games/",responses={
        200: {
            "model": GamesOutputDTO,
            "description": "Created game instance"
        }
    })
async def create_games(body: GameCreateSchema):

    game : GamesOutputDTO = await AppService().games_creator(name=body.name)
    return JSONResponse(status_code=200, content=game.model_dump())

@router.put("/games/{games_id}/",responses={
        200: {
            "model": GamesOutputDTO,
            "description": "Updated game instance"},
        404: {"Description": "game not found"}
        }
    )
async def update_games(game_id: int, body: GameUpdateSchema):

    game : GamesOutputDTO | None = await AppService().games_updater(game_id=game_id, name=body.name)
    if game is None:
        raise HTTPException(status_code=404, detail="Game not found")
    return game

@router.delete("/games/{games_id}/",responses={
        200: {
            "model": GamesOutputDTO,
            "description": "id of the deleted instance"},
        404: {"Description": "game not found"}
        }
    )
async def delete_game(game_id: int):
    deleted_id : int | None = await AppService().games_deleter(game_id=game_id)
    if deleted_id is None:
        raise HTTPException(status_code=404, detail="Game not found")
    return {"deleted_id": deleted_id}
