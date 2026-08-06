from apps.sports.models.models import SportModel
from apps.sports.models.ddo import SportDDO
from apps.sports.service.dto import SportOutputDTO


class AppService:

    def _to_output_dto(self, sport: SportDDO) -> SportOutputDTO:
        return SportOutputDTO(
            id=sport.id,
            name=sport.name,
            max_players_per_team=sport.max_players_per_team,
        )

    async def sports_lister(self) -> list[SportOutputDTO]:
        result: list[SportDDO] = await SportModel().list_sports()
        return [self._to_output_dto(s) for s in result]

    async def sports_getter(self, sport_id: int) -> SportOutputDTO:
        result: SportDDO = await SportModel().get_sport_by_id(sport_id=sport_id)
        return self._to_output_dto(result)
