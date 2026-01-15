from backend.models.models import GameModel
from backend.service.dto import GameDTO

class AppService():
    async def create_game(self,game_dto : GameDTO):
        
        result : GameDDO = await GameModel().insert_game()

        return GameDTO()