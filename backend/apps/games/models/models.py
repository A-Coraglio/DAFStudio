from backend.apps.games.models.ddo import PlayerDDO
async def get_player(self,player_id):
    player = "select * from player where id = $1"


    player_ddo = PlayerDDO(id=player["id"])
    return player_ddo

class GameModel():
    async def insert_game(self, datos):
        "se crea un game"
        return
        "select * from canchas wher empresa_id = 3"
