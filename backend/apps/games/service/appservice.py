
from apps.games.service.dto import UserOutputDTO
from apps.games.models.models import UserModel
from apps.games.models.ddo import UserDDO


class AppService():
    async def user_lister(self) -> list[UserOutputDTO]:
        
        result : list[UserDDO] = await UserModel().list_users()
        return [UserOutputDTO(id=i.id, name=i.name) for i in result]