from collections import Counter
from datetime import datetime
from traceback import format_exc

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
_RANKED_MODES = ("competitive",)
# Hours after `scheduled_at` before the auto-settle job is allowed to close
# a game. Generous (24h) so players who report from home that night still
# count; shorter would surprise users mid-dispute.
_SETTLE_GRACE_HOURS = 24


class AppService:

    def _to_output_dto(
        self,
        game: GameDDO,
        current_players: int = 0,
        confirmations_count: int | None = None,
        confirmations_total: int | None = None,
    ) -> GamesOutputDTO:
        return GamesOutputDTO(
            id=game.id,
            name=game.name,
            sport_id=game.sport_id,
            sport_name=game.sport_name,
            distance_km=game.distance_km,
            court_name=game.court_name,
            court_lat=game.court_lat,
            court_lon=game.court_lon,
            is_joined=game.is_joined,
            organizer_id=game.organizer_id,
            organizer_ranking_points=game.organizer_ranking_points,
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
            sets=game.sets,
            created_at=iso_utc(game.created_at),
            confirmations_count=confirmations_count,
            confirmations_total=confirmations_total,
        )

    async def _game_to_dto_with_count(self, game: GameDDO) -> GamesOutputDTO:
        count = await GamePlayerModel().count_players(game_id=game.id)
        return self._to_output_dto(game, current_players=count)

    async def _game_to_dto_with_confirmations(
        self, game: GameDDO
    ) -> GamesOutputDTO:
        """Detail-screen variant: also reports how many of the participants
        have submitted a result confirmation, so the UI can render "2/4
        jugadores reportaron" without an extra request."""
        participants = await GamePlayerModel().list_players(game_id=game.id)
        confirmations = await GameResultConfirmationModel().list_confirmations(
            game_id=game.id
        )
        return self._to_output_dto(
            game,
            current_players=len(participants),
            confirmations_count=len(confirmations),
            confirmations_total=len(participants),
        )

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
        for_user_id: int | None = None,
        court_id: int | None = None,
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
            for_user_id=for_user_id,
            court_id=court_id,
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
        return await self._game_to_dto_with_confirmations(result)

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
        # Ranking shown is per the game's sport, not an overall number.
        game = await GamesModel().get_game_by_id(game_id=game_id)
        sport_ranking = await PlayerModel().list_sport_rankings(
            sport_id=game.sport_id, player_ids=[r.player_id for r in rows]
        )
        result: list[GamePlayerOutputDTO] = []
        for row in rows:
            profile = profile_by_id.get(row.player_id)
            avatar_path = profile.avatar_path if profile else None
            result.append(GamePlayerOutputDTO(
                game_id=row.game_id,
                player_id=row.player_id,
                team_id=row.team_id,
                position=row.position,
                created_at=iso_utc(row.created_at),
                first_name=profile.first_name if profile else None,
                last_name=profile.last_name if profile else None,
                level=profile.level if profile else None,
                ranking_points=sport_ranking.get(row.player_id, 1000),
                avatar_url=f"/uploads/{avatar_path}" if avatar_path else None,
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
        position: int | None = None,
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

        if position is not None:
            if position >= game.max_players:
                raise GameStateException(
                    message="Position is out of range", error_code=400
                )
            taken = await GamePlayerModel().taken_positions(game_id=game_id)
            if position in taken:
                raise GameStateException(message="Position already taken")

        await GamePlayerModel().add_player(
            game_id=game_id, player_id=player.id, team_id=team_id,
            position=position,
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
        reported_home: int | None = None,
        reported_away: int | None = None,
        sets: list | None = None,
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

        # Set-based sports send `sets`; result_home/away become the SETS won and
        # the per-set detail is stored as "6-4,6-3". Single-score sports send
        # reported_home/reported_away directly.
        sets_str: str | None = None
        if sets:
            valid = [s for s in sets if s.home != 0 or s.away != 0]
            if not valid:
                raise GameStateException(message="Cargá al menos un set")
            reported_home = sum(1 for s in valid if s.home > s.away)
            reported_away = sum(1 for s in valid if s.away > s.home)
            sets_str = ",".join(f"{s.home}-{s.away}" for s in valid)
        else:
            reported_home = reported_home or 0
            reported_away = reported_away or 0

        await GameResultConfirmationModel().upsert_confirmation(
            game_id=game_id,
            player_id=player.id,
            reported_home=reported_home,
            reported_away=reported_away,
            sets=sets_str,
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
            sets=first.sets,
        )
        await self._apply_elo(finalized or game)
        return await self._game_to_dto_with_count(finalized or game)

    # -------- ELO --------

    async def _apply_elo(self, game: GameDDO) -> None:
        """Adjusts ranking_points for all participants after a ranked-mode
        game finalizes. Uses classic chess ELO per team (avg of team's
        rankings). Home team = players whose chosen position falls in the
        first half of the slots; players without a position are balanced in
        by join order (which keeps the legacy join-order split for games
        where nobody picked a spot). Casual games skip ranking entirely.
        """
        if game.mode not in _RANKED_MODES:
            return
        if game.result_home is None or game.result_away is None:
            return

        game_players = await GamePlayerModel().list_players(game_id=game.id)
        if len(game_players) < 2:
            return

        home_slots = game.max_players // 2
        home_gps = [
            gp for gp in game_players
            if gp.position is not None and gp.position < home_slots
        ]
        away_gps = [
            gp for gp in game_players
            if gp.position is not None and gp.position >= home_slots
        ]
        # Unpositioned players fill home up to half the roster (join order),
        # then away — for odd counts the larger team goes away, as before.
        mid = len(game_players) // 2
        for gp in game_players:
            if gp.position is not None:
                continue
            (home_gps if len(home_gps) < mid else away_gps).append(gp)
        if not home_gps or not away_gps:
            return

        # Ranking is per-sport: a game only moves the players' ranking IN the
        # sport being played.
        player_ids = [gp.player_id for gp in game_players]
        ranking_by_id = await PlayerModel().list_sport_rankings(
            sport_id=game.sport_id, player_ids=player_ids
        )

        avg_home = sum(ranking_by_id.get(gp.player_id, 1000) for gp in home_gps) / len(home_gps)
        avg_away = sum(ranking_by_id.get(gp.player_id, 1000) for gp in away_gps) / len(away_gps)

        # Actual score for home team.
        if game.result_home > game.result_away:
            actual_home = 1.0
        elif game.result_home < game.result_away:
            actual_home = 0.0
        else:
            actual_home = 0.5

        expected_home = 1.0 / (1.0 + 10 ** ((avg_away - avg_home) / 400.0))
        delta = round(_ELO_K_FACTOR * (actual_home - expected_home))

        # Per-sport ranking is the source of truth; player.ranking_points is
        # kept updated too as a denormalised "overall" for the players search.
        for gp in home_gps:
            await PlayerModel().adjust_sport_ranking(
                gp.player_id, game.sport_id, delta
            )
            await PlayerModel().adjust_ranking_points(
                player_id=gp.player_id, delta=delta
            )
        for gp in away_gps:
            await PlayerModel().adjust_sport_ranking(
                gp.player_id, game.sport_id, -delta
            )
            await PlayerModel().adjust_ranking_points(
                player_id=gp.player_id, delta=-delta
            )

    # -------- auto-settle --------

    async def settle_pending_results(self) -> dict[str, int]:
        """Closes games whose scheduled_at is more than `_SETTLE_GRACE_HOURS`
        in the past and that are still open/full. Three outcomes per game:

          * no confirmations    → finished WITHOUT result, no ELO.
          * clear majority      → that score wins (set_result + _apply_elo).
          * tied / no majority  → finished WITHOUT result, no ELO.

        Called by the scheduler in loader_app. Returns a small summary so
        ops can grep logs and see what the job did.
        """
        candidates = await GamesModel().list_pending_settlement(
            grace_hours=_SETTLE_GRACE_HOURS
        )
        stats = {"checked": len(candidates), "finalized": 0, "no_result": 0}
        for game in candidates:
            try:
                outcome = await self._settle_one(game)
            except Exception:
                # One bad game shouldn't poison the whole sweep — log and
                # move on. Next run will pick it up again.
                print(
                    f"[settle] failed for game {game.id}:\n" + format_exc()
                )
                continue
            stats[outcome] = stats.get(outcome, 0) + 1
        return stats

    async def _settle_one(self, game: GameDDO) -> str:
        confirmations = await GameResultConfirmationModel().list_confirmations(
            game_id=game.id
        )
        if not confirmations:
            await GamesModel().finish_without_result(game_id=game.id)
            return "no_result"

        # Tally votes per (home, away) score pair. Counter.most_common gives
        # us the leader; we check the runner-up to detect ties.
        votes = Counter(
            (c.reported_home, c.reported_away) for c in confirmations
        )
        ranked = votes.most_common()
        top_score, top_count = ranked[0]
        if len(ranked) > 1 and ranked[1][1] == top_count:
            # Tied vote — can't pick a winner fairly. Close without result.
            await GamesModel().finish_without_result(game_id=game.id)
            return "no_result"

        finalized = await GamesModel().set_result(
            game_id=game.id,
            result_home=top_score[0],
            result_away=top_score[1],
        )
        await self._apply_elo(finalized or game)
        return "finalized"
