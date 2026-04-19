from apps.players.models.models import PlayerModel
from apps.players.models.ddo import PlayerDDO
from apps.players.service.dto import PlayerOutputDTO, UpdatePlayerInputDTO
from apps.players.exceptions.exceptions import (
    PlayerNotFoundException,
    PlayerAlreadyExistsException,
)


class AppService:

    def _to_output_dto(self, player: PlayerDDO) -> PlayerOutputDTO:
        return PlayerOutputDTO(
            id=player.id,
            user_id=player.user_id,
            first_name=player.first_name,
            last_name=player.last_name,
            level=player.level,
            ranking_points=player.ranking_points,
            favorite_sport_id=player.favorite_sport_id,
        )

    async def players_getter_by_id(self, player_id: int) -> PlayerOutputDTO:
        player = await PlayerModel().get_player_by_id(player_id=player_id)
        return self._to_output_dto(player)

    async def players_getter_by_user_id(self, user_id: int) -> PlayerOutputDTO:
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"No player profile for user {user_id}"
            )
        return self._to_output_dto(player)

    async def players_creator(self, user_id: int) -> PlayerOutputDTO:
        """Creates an empty player profile paired to a freshly-registered user.
        All profile fields (name, sport, level) are filled later via the
        onboarding flow → `players_updater_by_user_id`.
        """
        existing = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if existing is not None:
            raise PlayerAlreadyExistsException()
        player = await PlayerModel().create_player(user_id=user_id)
        return self._to_output_dto(player)

    async def players_updater_by_user_id(
        self, user_id: int, data: UpdatePlayerInputDTO
    ) -> PlayerOutputDTO:
        existing = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if existing is None:
            raise PlayerNotFoundException(
                message=f"No player profile for user {user_id}"
            )
        updated = await PlayerModel().update_player(
            player_id=existing.id,
            first_name=data.first_name,
            last_name=data.last_name,
            level=data.level,
            favorite_sport_id=data.favorite_sport_id,
        )
        return self._to_output_dto(updated or existing)
