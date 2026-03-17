
from apps.games.service.dto import GamesOutputDTO
from apps.games.models.models import GamesModel
from apps.games.models.ddo import GameDDO


class AppService():
    async def games_lister(self) -> list[GamesOutputDTO]:
        
        result : list[GameDDO] = await GamesModel().list_games()
        return [GamesOutputDTO(id=i.id, name=i.name) for i in result]