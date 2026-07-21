from apps.tournaments.models.models import TournamentModel
from apps.tournaments.models.ddo import TournamentDDO
from apps.tournaments.models.participants import (
    TournamentParticipantDDO,
    TournamentParticipantModel,
)
from apps.tournaments.service.dto import (
    TournamentOutputDTO,
    TournamentParticipantOutputDTO,
)
from apps.players.exceptions.exceptions import PlayerNotFoundException
from apps.players.models.models import PlayerModel


class AppService:

    def _to_output_dto(self, tournament: TournamentDDO) -> TournamentOutputDTO:
        return TournamentOutputDTO(**tournament.model_dump())

    def _participant_to_dto(
        self, participant: TournamentParticipantDDO
    ) -> TournamentParticipantOutputDTO:
        return TournamentParticipantOutputDTO(
            player_id=participant.player_id,
            user_id=participant.user_id,
            display_name=participant.display_name,
            level=participant.level,
            avatar_url=(
                f"/uploads/{participant.avatar_path}"
                if participant.avatar_path else None
            ),
            joined_at=participant.created_at,
        )

    async def _player_for_user(self, user_id: int):
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"El usuario {user_id} no tiene perfil de jugador"
            )
        return player

    async def tournaments_lister(
        self,
        sport_id: int | None = None,
        level: str | None = None,
        status: str | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> list[TournamentOutputDTO]:
        rows = await TournamentModel().list_tournaments(
            sport_id=sport_id,
            level=level,
            status=status,
            near_lat=near_lat,
            near_lon=near_lon,
            radius_km=radius_km,
            limit=limit,
            offset=offset,
        )
        return [self._to_output_dto(t) for t in rows]

    async def tournaments_getter(self, tournament_id: int) -> TournamentOutputDTO:
        result = await TournamentModel().get_tournament_by_id(
            tournament_id=tournament_id
        )
        return self._to_output_dto(result)

    async def tournaments_recommended(
        self,
        current_user_id: int,
        near_lat: float | None = None,
        near_lon: float | None = None,
        limit: int = 8,
        sport_id: int | None = None,
    ) -> list[TournamentOutputDTO]:
        """Personalised strip: reads the user's favorite sport + level from
        their player profile and ranks upcoming tournaments by that plus the
        (client-provided) location. [sport_id] (the home sport selector) is a
        hard filter on top of the soft ranking."""
        player = await PlayerModel().get_player_by_user_id(user_id=current_user_id)
        favorite_sport_id = player.favorite_sport_id if player else None
        level = player.level if player else None
        rows = await TournamentModel().recommend_tournaments(
            favorite_sport_id=favorite_sport_id,
            level=level,
            near_lat=near_lat,
            near_lon=near_lon,
            limit=limit,
            sport_id=sport_id,
        )
        return [self._to_output_dto(t) for t in rows]

    async def tournament_participants_lister(
        self, tournament_id: int
    ) -> list[TournamentParticipantOutputDTO]:
        # 404 first so an empty list always means "nobody enrolled yet".
        await TournamentModel().get_tournament_by_id(tournament_id=tournament_id)
        rows = await TournamentParticipantModel().list_participants(
            tournament_id=tournament_id
        )
        return [self._participant_to_dto(p) for p in rows]

    async def tournament_joiner(
        self, tournament_id: int, current_user_id: int
    ) -> TournamentOutputDTO:
        player = await self._player_for_user(current_user_id)
        # Status / capacity / double-join checks live inside join_atomic:
        # they must run under the same row lock as the insert.
        await TournamentParticipantModel().join_atomic(
            tournament_id=tournament_id, player_id=player.id
        )
        return await self.tournaments_getter(tournament_id=tournament_id)

    async def tournament_leaver(
        self, tournament_id: int, current_user_id: int
    ) -> TournamentOutputDTO:
        player = await self._player_for_user(current_user_id)
        await TournamentParticipantModel().leave_atomic(
            tournament_id=tournament_id, player_id=player.id
        )
        return await self.tournaments_getter(tournament_id=tournament_id)
