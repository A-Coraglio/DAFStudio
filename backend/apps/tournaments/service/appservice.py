from apps.tournaments.models.models import TournamentModel
from apps.tournaments.models.ddo import TournamentDDO
from apps.tournaments.service.dto import TournamentOutputDTO
from apps.players.models.models import PlayerModel


class AppService:

    def _to_output_dto(self, tournament: TournamentDDO) -> TournamentOutputDTO:
        return TournamentOutputDTO(**tournament.model_dump())

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
    ) -> list[TournamentOutputDTO]:
        """Personalised strip: reads the user's favorite sport + level from
        their player profile and ranks upcoming tournaments by that plus the
        (client-provided) location."""
        player = await PlayerModel().get_player_by_user_id(user_id=current_user_id)
        favorite_sport_id = player.favorite_sport_id if player else None
        level = player.level if player else None
        rows = await TournamentModel().recommend_tournaments(
            favorite_sport_id=favorite_sport_id,
            level=level,
            near_lat=near_lat,
            near_lon=near_lon,
            limit=limit,
        )
        return [self._to_output_dto(t) for t in rows]
