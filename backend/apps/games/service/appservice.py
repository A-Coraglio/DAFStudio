
from apps.games.service.dto import GamesOutputDTO
from apps.games.models.models import GamesModel
from apps.games.models.ddo import GameDDO


class AppService():
    async def games_lister(self) -> list[GamesOutputDTO]:
        
        result : list[GameDDO] = await GamesModel().list_games()
        return [GamesOutputDTO(id=i.id, 
                               name=i.name,
                               sport_id=i.sport_id,
                               organizer_id=i.organizer_id,
                               max_players=i.max_players,
                               level=i.level,
                               status=i.status,
                               created_at=i.created_at.isoformat()) for i in result]
    
    #async def create_game(self, data: GameCreateDTO):