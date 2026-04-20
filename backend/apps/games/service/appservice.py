from datetime import datetime

from apps.games.service.iso_utils import iso_utc
from apps.games.service.dto import (
    GamesOutputDTO,
    GameCreateInputDTO,
    GameUpdateInputDTO,
    GamePlayerOutputDTO,
    GAME_MODES,
)
from apps.games.models.models import GamesModel
from apps.games.models.ddo import GameDDO
from apps.games.models.game_player import GamePlayerModel
from apps.games.models.game_result_confirmation import GameResultConfirmationModel
from apps.games.exceptions.exceptions import (
    GameForbiddenException,
    GameStateException,
)
from apps.players.models.models import PlayerModel
from apps.players.exceptions.exceptions import PlayerNotFoundException


# Classic chess ELO: K=32 is the usual amateur value. Higher K swings
# rankings faster (good for a new app bootstrapping rankings); lower K
# stabilizes an established ranking.
_ELO_K_FACTOR = 32
# Modes whose result updates player rankings. Casual is intentionally excluded.
_RANKED_MODES = ("competitive", "matchmaking")


class AppService:

    def _to_output_dto(
        self, game: GameDDO, current_players: int = 0
    ) -> GamesOutputDTO:
        return GamesOutputDTO(
            id=game.id,
            name=game.name,
            sport_id=game.sport_id,
            organizer_id=game.organizer_id,
            court_id=game.court_id,
            max_players=game.max_players,
            current_players=current_players,
            level=game.level,
            mode=game.mode,
            status=game.status,
            # scheduled_at is "when the organizer wants to play" — user-picked
            # naive local time, echoed verbatim so it renders as chosen.
            scheduled_at=game.scheduled_at.isoformat() if game.scheduled_at else None,
            result_home=game.result_home,
            result_away=game.result_away,
            created_at=iso_utc(game.created_at),
        )

    async def _game_to_dto_with_count(self, game: GameDDO) -> GamesOutputDTO:
        count = await GamePlayerModel().count_players(game_id=game.id)
        return self._to_output_dto(game, current_players=count)

    async def games_lister(
        self,
        sport_id: int | None = None,
        mode: str | None = None,
        level: str | None = None,
        status: str | None = None,
        organizer_id: int | None = None,
        scheduled_after: datetime | None = None,
        scheduled_before: datetime | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
    ) -> list[GamesOutputDTO]:
        games: list[GameDDO] = await GamesModel().list_games(
            sport_id=sport_id,
            mode=mode,
            level=level,
            status=status,
            organizer_id=organizer_id,
            scheduled_after=scheduled_after,
            scheduled_before=scheduled_before,
            near_lat=near_lat,
            near_lon=near_lon,
            radius_km=radius_km,
        )
        counts = await GamePlayerModel().counts_by_game_ids(
            [g.id for g in games]
        )
        return [
            self._to_output_dto(g, current_players=counts.get(g.id, 0))
            for g in games
        ]

    async def games_getter(self, game_id: int) -> GamesOutputDTO:
        result: GameDDO = await GamesModel().get_game_by_id(game_id=game_id)
        return await self._game_to_dto_with_count(result)

    async def games_creator(
        self, data: GameCreateInputDTO, organizer_id: int
    ) -> GamesOutputDTO:
        if data.mode not in GAME_MODES:
            raise GameStateException(
                message=f"mode must be one of {GAME_MODES}", error_code=400
            )
        result: GameDDO = await GamesModel().create_game(
            name=data.name,
            sport_id=data.sport_id,
            max_players=data.max_players,
            organizer_id=organizer_id,
            mode=data.mode,
            level=data.level,
            court_id=data.court_id,
            scheduled_at=data.scheduled_at,
        )
        return self._to_output_dto(result)

    async def games_updater(
        self,
        game_id: int,
        data: GameUpdateInputDTO,
        current_user_id: int,
    ) -> GamesOutputDTO:
        existing = await GamesModel().get_game_by_id(game_id=game_id)
        if existing.organizer_id != current_user_id:
            raise GameForbiddenException()

        updated = await GamesModel().update_game(
            game_id=game_id,
            name=data.name,
            max_players=data.max_players,
            court_id=data.court_id,
            level=data.level,
            scheduled_at=data.scheduled_at,
            status=data.status,
        )
        return await self._game_to_dto_with_count(updated or existing)

    async def games_deleter(self, game_id: int, current_user_id: int) -> int:
        existing = await GamesModel().get_game_by_id(game_id=game_id)
        if existing.organizer_id != current_user_id:
            raise GameForbiddenException()
        return await GamesModel().delete_game(game_id=game_id)

    async def game_players_lister(
        self, game_id: int
    ) -> list[GamePlayerOutputDTO]:
        """Returns participants enriched with name + ranking_points. Uses a
        single batch query against player so the detail screen never does N+1."""
        rows = await GamePlayerModel().list_players(game_id=game_id)
        profiles = await PlayerModel().list_players_by_ids(
            [r.player_id for r in rows]
        )
        profile_by_id = {p.id: p for p in profiles}
        result: list[GamePlayerOutputDTO] = []
        for row in rows:
            profile = profile_by_id.get(row.player_id)
            result.append(GamePlayerOutputDTO(
                game_id=row.game_id,
                player_id=row.player_id,
                team_id=row.team_id,
                created_at=iso_utc(row.created_at),
                first_name=profile.first_name if profile else None,
                last_name=profile.last_name if profile else None,
                level=profile.level if profile else None,
                ranking_points=profile.ranking_points if profile else 0,
            ))
        return result

    # -------- participants --------

    async def _player_for_user(self, user_id: int):
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"No player profile for user {user_id}"
            )
        return player

    async def game_join(
        self,
        game_id: int,
        current_user_id: int,
        team_id: int | None = None,
    ) -> GamesOutputDTO:
        game = await GamesModel().get_game_by_id(game_id=game_id)
        if game.status != "open":
            raise GameStateException(
                message=f"Cannot join a '{game.status}' game"
            )

        player = await self._player_for_user(current_user_id)

        if await GamePlayerModel().is_player_in_game(
            game_id=game_id, player_id=player.id
        ):
            raise GameStateException(message="You already joined this game")

        current_count = await GamePlayerModel().count_players(game_id=game_id)
        if current_count >= game.max_players:
            raise GameStateException(message="Game is full")

        await GamePlayerModel().add_player(
            game_id=game_id, player_id=player.id, team_id=team_id
        )

        # Flip to 'full' if we just filled the last slot.
        if current_count + 1 >= game.max_players:
            updated = await GamesModel().update_game(game_id=game_id, status="full")
            return await self._game_to_dto_with_count(updated or game)
        return await self._game_to_dto_with_count(game)

    async def game_leave(
        self, game_id: int, current_user_id: int
    ) -> GamesOutputDTO:
        game = await GamesModel().get_game_by_id(game_id=game_id)
        if game.status not in ("open", "full"):
            raise GameStateException(
                message=f"Cannot leave a '{game.status}' game"
            )

        player = await self._player_for_user(current_user_id)
        removed = await GamePlayerModel().remove_player(
            game_id=game_id, player_id=player.id
        )
        if not removed:
            raise GameStateException(message="You are not in this game")

        # If the game was full, it now has space — reopen.
        if game.status == "full":
            updated = await GamesModel().update_game(game_id=game_id, status="open")
            return await self._game_to_dto_with_count(updated or game)
        return await self._game_to_dto_with_count(game)

    # -------- result reporting --------

    async def game_report_result(
        self,
        game_id: int,
        current_user_id: int,
        reported_home: int,
        reported_away: int,
    ) -> GamesOutputDTO:
        game = await GamesModel().get_game_by_id(game_id=game_id)
        if game.status not in ("open", "full"):
            raise GameStateException(
                message=f"Cannot report result for a '{game.status}' game"
            )

        player = await self._player_for_user(current_user_id)
        if not await GamePlayerModel().is_player_in_game(
            game_id=game_id, player_id=player.id
        ):
            raise GameStateException(
                message="Only participants can report the result"
            )

        await GameResultConfirmationModel().upsert_confirmation(
            game_id=game_id,
            player_id=player.id,
            reported_home=reported_home,
            reported_away=reported_away,
        )

        # Consensus rule: when every participant has reported the SAME score,
        # finalize the game. If votes conflict, do nothing — wait for someone
        # to change their mind. A background job will later mark un-reported
        # games as draws.
        participants = await GamePlayerModel().list_players(game_id=game_id)
        confirmations = await GameResultConfirmationModel().list_confirmations(
            game_id=game_id
        )
        if len(confirmations) < len(participants) or not participants:
            return await self._game_to_dto_with_count(game)

        first = confirmations[0]
        all_agree = all(
            c.reported_home == first.reported_home
            and c.reported_away == first.reported_away
            for c in confirmations
        )
        if not all_agree:
            return await self._game_to_dto_with_count(game)

        finalized = await GamesModel().set_result(
            game_id=game_id,
            result_home=first.reported_home,
            result_away=first.reported_away,
        )
        await self._apply_elo(finalized or game)
        return await self._game_to_dto_with_count(finalized or game)

    # -------- ELO --------

    async def _apply_elo(self, game: GameDDO) -> None:
        """Adjusts ranking_points for all participants after a ranked-mode
        game finalizes. Uses classic chess ELO per team (avg of team's
        rankings). Home team = first half of players by join order; away =
        rest. Casual games skip ranking entirely.
        """
        if game.mode not in _RANKED_MODES:
            return
        if game.result_home is None or game.result_away is None:
            return

        game_players = await GamePlayerModel().list_players(game_id=game.id)
        if len(game_players) < 2:
            return

        # Split by join order. For odd player counts (user-created games),
        # the larger team goes away.
        mid = len(game_players) // 2
        home_gps = game_players[:mid]
        away_gps = game_players[mid:]
        if not home_gps or not away_gps:
            return

        players = await PlayerModel().list_players_by_ids(
            [gp.player_id for gp in game_players]
        )
        ranking_by_id = {p.id: p.ranking_points for p in players}

        avg_home = sum(ranking_by_id.get(gp.player_id, 0) for gp in home_gps) / len(home_gps)
        avg_away = sum(ranking_by_id.get(gp.player_id, 0) for gp in away_gps) / len(away_gps)

        # Actual score for home team.
        if game.result_home > game.result_away:
            actual_home = 1.0
        elif game.result_home < game.result_away:
            actual_home = 0.0
        else:
            actual_home = 0.5

        expected_home = 1.0 / (1.0 + 10 ** ((avg_away - avg_home) / 400.0))
        delta = round(_ELO_K_FACTOR * (actual_home - expected_home))

        for gp in home_gps:
            await PlayerModel().adjust_ranking_points(
                player_id=gp.player_id, delta=delta
            )
        for gp in away_gps:
            await PlayerModel().adjust_ranking_points(
                player_id=gp.player_id, delta=-delta
            )
