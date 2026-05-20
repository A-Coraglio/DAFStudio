import os
import secrets
import shutil
from pathlib import Path

from apps.games.models.ddo import GameDDO
from apps.games.models.game_player import GamePlayerModel
from apps.games.models.models import GamesModel
from apps.games.service.appservice import AppService as GamesAppService
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
                message=f"No player profile for user {user_id}"
            )
        games = await GamesModel().list_games_for_player(
            player_id=player.id,
            status=status,
            mode=mode,
            limit=limit,
            offset=offset,
        )
        return [
            await self._game_to_my_dto(game=g, player_id=player.id)
            for g in games
        ]

    async def my_stats(self, user_id: int) -> PlayerStatsOutputDTO:
        """Aggregate W/L/D + ranking. Walks all finished games where the user
        participated and tallies based on the same home/away split rule that
        ELO uses, so the stats and the ranking are consistent."""
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"No player profile for user {user_id}"
            )
        # Pull everything finished — no limit. If the per-user history ever
        # explodes we can switch to a per-mode aggregate query, but for now
        # this is the simplest correct version.
        finished = await GamesModel().list_games_for_player(
            player_id=player.id, status="finished", limit=10_000, offset=0,
        )
        wins = losses = draws = casual = total_with_result = 0
        for game in finished:
            if game.mode == "casual":
                casual += 1
                continue
            outcome, _ = await self._player_outcome(
                game=game, player_id=player.id,
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
        return PlayerStatsOutputDTO(
            ranking_points=player.ranking_points,
            total_played=total_with_result,
            wins=wins,
            losses=losses,
            draws=draws,
            casual_played=casual,
        )

    async def _game_to_my_dto(
        self, game: GameDDO, player_id: int,
    ) -> MyGameOutputDTO:
        outcome, side = await self._player_outcome(
            game=game, player_id=player_id,
        )
        # Build on top of the standard GamesOutputDTO so the shape stays
        # consistent with /api/games/ — the frontend can render with the same
        # widgets and just read the extra fields.
        base = await GamesAppService()._game_to_dto_with_count(game)
        return MyGameOutputDTO(
            **base.model_dump(),
            outcome=outcome,
            team_side=side,
        )

    async def _player_outcome(
        self, game: GameDDO, player_id: int,
    ) -> tuple[str, str | None]:
        """Replicates the team-split rule from `_apply_elo` so the outcome
        the user sees in their history matches the ELO that was applied:
        first half by join order = home, rest = away."""
        if game.result_home is None or game.result_away is None:
            return "pending", None
        game_players = await GamePlayerModel().list_players(game_id=game.id)
        if len(game_players) < 2:
            return "pending", None
        mid = len(game_players) // 2
        home_ids = {gp.player_id for gp in game_players[:mid]}
        away_ids = {gp.player_id for gp in game_players[mid:]}
        if player_id in home_ids:
            side = "home"
        elif player_id in away_ids:
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
                message=f"No player profile for user {user_id}"
            )
        ext = os.path.splitext(filename)[1].lower()
        if ext not in ALLOWED_AVATAR_EXT:
            raise ValueError(f"Unsupported avatar extension: {ext}")

        AVATAR_DIR.mkdir(parents=True, exist_ok=True)
        new_name = f"p{existing.id}_{secrets.token_hex(8)}{ext}"
        dest = AVATAR_DIR / new_name
        with dest.open("wb") as out:
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
