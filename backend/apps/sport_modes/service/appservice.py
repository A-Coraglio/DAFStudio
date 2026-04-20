from apps.sport_modes.models.models import SportModeModel
from apps.sport_modes.models.ddo import SportModeDDO
from apps.sport_modes.service.dto import (
    SportModeCreateInputDTO,
    SportModeOutputDTO,
)


class AppService:

    def _to_output_dto(self, mode: SportModeDDO) -> SportModeOutputDTO:
        return SportModeOutputDTO(
            id=mode.id,
            sport_id=mode.sport_id,
            name=mode.name,
            max_players_per_team=mode.max_players_per_team,
        )

    async def list_modes(
        self, sport_id: int | None = None
    ) -> list[SportModeOutputDTO]:
        rows = (
            await SportModeModel().list_for_sport(sport_id=sport_id)
            if sport_id is not None
            else await SportModeModel().list_all()
        )
        return [self._to_output_dto(r) for r in rows]

    async def get_mode(self, mode_id: int) -> SportModeOutputDTO:
        mode = await SportModeModel().get_by_id(mode_id=mode_id)
        return self._to_output_dto(mode)

    async def create_mode(
        self, data: SportModeCreateInputDTO
    ) -> SportModeOutputDTO:
        mode = await SportModeModel().create(
            sport_id=data.sport_id,
            name=data.name,
            max_players_per_team=data.max_players_per_team,
        )
        return self._to_output_dto(mode)
