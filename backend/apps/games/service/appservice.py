from apps.games.service.dto import GamesOutputDTO
from apps.games.models.models import GamesModel
from apps.games.models.ddo import GameDDO


class AppService():

    def _to_output_dto(self, game: GameDDO) -> GamesOutputDTO:
        return GamesOutputDTO(
            id=game.id,
            name=game.name,
            sport_id=game.sport_id,
            organizer_id=game.organizer_id,
            max_players=game.max_players,
            level=game.level,
            status=game.status,
            created_at=game.created_at.isoformat()
        )
    
    async def games_lister(self) -> list[GamesOutputDTO]:
        result: list[GameDDO] = await GamesModel().list_games()
        return [self._to_output_dto(i) for i in result]

    async def games_creator(self, name: str) -> GamesOutputDTO:
        result: GameDDO = await GamesModel().create_game(name=name)
        return self._to_output_dto(result)

    async def games_getter(self, game_id: int) -> GamesOutputDTO :
        result: GameDDO = await GamesModel().get_game_by_id(game_id=game_id)
        return self._to_output_dto(result)

    async def games_updater(self, game_id: int, name: str) -> GamesOutputDTO :
        result: GameDDO = await GamesModel().update_game(game_id=game_id, name=name)
        return self._to_output_dto(result)

    async def games_deleter(self, game_id: int) -> int :
        deleted_id: int = await GamesModel().delete_game(game_id=game_id)
        return deleted_id
