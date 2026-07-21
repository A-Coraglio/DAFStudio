import os
import secrets
import shutil
from pathlib import Path

from apps.games.models.ddo import GameDDO
from apps.games.models.game_player import GamePlayerDDO, GamePlayerModel
from apps.games.models.models import GamesModel
from apps.games.service.appservice import AppService as GamesAppService
from apps.games.service.team_split import split_home_away
from apps.players.models.models import PlayerModel
from apps.players.models.ddo import PlayerDDO
from apps.players.service.dto import (
    MyGameOutputDTO,
    PlayerOutputDTO,
    PlayerStatsOutputDTO,
    UpdatePlayerInputDTO,
)
from apps.players.exceptions.exceptions import (
    PlayerNotFoundException,
    PlayerAlreadyExistsException,
)


# Root on disk for user uploads. Mounted at /uploads/ by the FastAPI app so
# clients can fetch `<apiBaseUrl>/uploads/avatars/<file>`.
UPLOADS_ROOT = Path(__file__).resolve().parents[3] / "uploads"
AVATAR_DIR = UPLOADS_ROOT / "avatars"
ALLOWED_AVATAR_EXT = {".png", ".jpg", ".jpeg", ".webp"}
MAX_AVATAR_BYTES = 2 * 1024 * 1024  # 2 MB


def _looks_like_image(head: bytes) -> bool:
    """Magic-bytes check for the formats in ALLOWED_AVATAR_EXT."""
    return (
        head.startswith(b"\x89PNG\r\n\x1a\n")
        or head.startswith(b"\xff\xd8\xff")
        or (head[:4] == b"RIFF" and head[8:12] == b"WEBP")
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
            avatar_url=f"/uploads/{player.avatar_path}" if player.avatar_path else None,
        )

    async def players_getter_by_id(self, player_id: int) -> PlayerOutputDTO:
        player = await PlayerModel().get_player_by_id(player_id=player_id)
        return self._to_output_dto(player)

    async def players_search(
        self,
        query: str | None,
        sport_id: int | None,
        level: str | None,
        exclude_user_id: int | None,
        limit: int,
        offset: int,
    ) -> list[PlayerOutputDTO]:
        players = await PlayerModel().search_players(
            query=query,
            sport_id=sport_id,
            level=level,
            exclude_user_id=exclude_user_id,
            limit=limit,
            offset=offset,
        )
        return [self._to_output_dto(p) for p in players]

    async def players_getter_by_user_id(self, user_id: int) -> PlayerOutputDTO:
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"El usuario {user_id} no tiene perfil de jugador"
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
                message=f"El usuario {user_id} no tiene perfil de jugador"
            )
        updated = await PlayerModel().update_player(
            player_id=existing.id,
            first_name=data.first_name,
            last_name=data.last_name,
            level=data.level,
            favorite_sport_id=data.favorite_sport_id,
        )
        return self._to_output_dto(updated or existing)

    async def my_games(
        self,
        user_id: int,
        status: str | None,
        mode: str | None,
        limit: int,
        offset: int,
    ) -> list[MyGameOutputDTO]:
        """Personal history feed for the calling user. Each game is enriched
        with the player's own outcome (won/lost/draw/pending) and team side."""
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"El usuario {user_id} no tiene perfil de jugador"
            )
        games = await GamesModel().list_games_for_player(
            player_id=player.id,
            status=status,
            mode=mode,
            limit=limit,
            offset=offset,
        )
        return await self._games_to_my_dtos(games=games, player_id=player.id)

    async def my_stats(
        self, user_id: int, sport_id: int | None = None
    ) -> PlayerStatsOutputDTO:
        """Per-sport W/L/D + ranking when `sport_id` is given, otherwise an
        all-sports aggregate. Walks all finished games where the user
        participated and tallies based on the same home/away split rule that
        ELO uses, so the stats and the ranking stay consistent."""
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"El usuario {user_id} no tiene perfil de jugador"
            )
        return await self._stats_for_player(player, sport_id=sport_id)

    async def player_stats(
        self, player_id: int, sport_id: int | None = None
    ) -> PlayerStatsOutputDTO:
        """Public W/L/D of any player — same tally as my_stats. Backs the
        public profile screen."""
        player = await PlayerModel().get_player_by_id(player_id=player_id)
        return await self._stats_for_player(player, sport_id=sport_id)

    async def player_games(
        self, player_id: int, limit: int = 10, offset: int = 0,
    ) -> list[MyGameOutputDTO]:
        """Public recent history of any player, outcomes from their own
        perspective — same shape as my_games."""
        player = await PlayerModel().get_player_by_id(player_id=player_id)
        games = await GamesModel().list_games_for_player(
            player_id=player.id, status=None, mode=None,
            limit=limit, offset=offset,
        )
        return await self._games_to_my_dtos(games=games, player_id=player.id)

    async def _stats_for_player(
        self, player, sport_id: int | None = None
    ) -> PlayerStatsOutputDTO:
        # Pull everything finished — no limit. If the per-user history ever
        # explodes we can switch to a per-mode aggregate query, but for now
        # this is the simplest correct version. When `sport_id` is given, only
        # games of that sport count and the ranking is that sport's ranking.
        finished = await GamesModel().list_games_for_player(
            player_id=player.id, status="finished", limit=10_000, offset=0,
        )
        wins = losses = draws = casual = total_with_result = 0
        relevant: list[GameDDO] = []
        for game in finished:
            if sport_id is not None and game.sport_id != sport_id:
                continue
            if game.mode == "casual":
                casual += 1
                continue
            relevant.append(game)
        # One bulk roster fetch for every counted game — per-game lookups
        # here were the worst N+1 of the backend (10k games → 10k queries).
        rosters = await GamePlayerModel().list_players_by_game_ids(
            [g.id for g in relevant]
        )
        for game in relevant:
            outcome, _ = self._outcome_from_roster(
                game=game,
                roster=rosters.get(game.id, []),
                player_id=player.id,
            )
            if outcome == "pending":
                continue
            total_with_result += 1
            if outcome == "won":
                wins += 1
            elif outcome == "lost":
                losses += 1
            elif outcome == "draw":
                draws += 1
        ranking = (
            await PlayerModel().get_sport_ranking(player.id, sport_id)
            if sport_id is not None
            else player.ranking_points
        )
        return PlayerStatsOutputDTO(
            sport_id=sport_id,
            ranking_points=ranking,
            total_played=total_with_result,
            wins=wins,
            losses=losses,
            draws=draws,
            casual_played=casual,
        )

    async def _games_to_my_dtos(
        self, games: list[GameDDO], player_id: int,
    ) -> list[MyGameOutputDTO]:
        """History cards for a batch of games with ONE roster query total —
        the roster gives both the player count and the outcome, so no
        per-game lookups remain. Shape stays consistent with /api/games/
        (built on GamesOutputDTO) so the frontend reuses the same widgets."""
        rosters = await GamePlayerModel().list_players_by_game_ids(
            [g.id for g in games]
        )
        games_service = GamesAppService()
        result: list[MyGameOutputDTO] = []
        for game in games:
            roster = rosters.get(game.id, [])
            outcome, side = self._outcome_from_roster(
                game=game, roster=roster, player_id=player_id,
            )
            base = games_service._to_output_dto(
                game, current_players=len(roster)
            )
            result.append(MyGameOutputDTO(
                **base.model_dump(),
                outcome=outcome,
                team_side=side,
            ))
        return result

    def _outcome_from_roster(
        self,
        game: GameDDO,
        roster: list[GamePlayerDDO],
        player_id: int,
    ) -> tuple[str, str | None]:
        """Outcome from the player's perspective, using the SAME split rule
        as `_apply_elo` (games/service/team_split.py) — positions count when
        chosen, join order fills the rest — so the W/L shown always matches
        the ELO that was applied."""
        if game.result_home is None or game.result_away is None:
            return "pending", None
        if len(roster) < 2:
            return "pending", None
        home, away = split_home_away(roster, game.max_players)
        if player_id in {gp.player_id for gp in home}:
            side = "home"
        elif player_id in {gp.player_id for gp in away}:
            side = "away"
        else:
            return "pending", None

        if game.result_home == game.result_away:
            return "draw", side
        home_won = game.result_home > game.result_away
        if side == "home":
            return ("won" if home_won else "lost"), side
        return ("lost" if home_won else "won"), side

    async def set_avatar_for_user(
        self, user_id: int, filename: str, file_obj
    ) -> PlayerOutputDTO:
        """Persist a new avatar for the user. Writes the file with a random
        name to avoid collisions, replaces any previous avatar, and stores
        the relative path in the player row. Raises `ValueError` on invalid
        extension so the route can map it to a 400.
        """
        existing = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if existing is None:
            raise PlayerNotFoundException(
                message=f"El usuario {user_id} no tiene perfil de jugador"
            )
        ext = os.path.splitext(filename)[1].lower()
        if ext not in ALLOWED_AVATAR_EXT:
            raise ValueError(
                "Formato de avatar no soportado (usá PNG, JPG o WebP)"
            )

        # The extension is user-controlled — check the actual bytes so a
        # renamed script/HTML can't land in /uploads and be served back.
        head = file_obj.read(12)
        if not _looks_like_image(head):
            raise ValueError(
                "El archivo no es una imagen válida (PNG, JPG o WebP)"
            )

        AVATAR_DIR.mkdir(parents=True, exist_ok=True)
        new_name = f"p{existing.id}_{secrets.token_hex(8)}{ext}"
        dest = AVATAR_DIR / new_name
        with dest.open("wb") as out:
            out.write(head)
            shutil.copyfileobj(file_obj, out)

        if existing.avatar_path:
            old = UPLOADS_ROOT / existing.avatar_path
            try:
                if old.exists():
                    old.unlink()
            except OSError:
                pass  # best-effort cleanup of the previous file

        rel = f"avatars/{new_name}"
        updated = await PlayerModel().set_avatar_path(
            player_id=existing.id, avatar_path=rel
        )
        return self._to_output_dto(updated or existing)
