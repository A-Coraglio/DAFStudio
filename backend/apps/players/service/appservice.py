import os
import secrets
import shutil
from pathlib import Path

from apps.players.models.models import PlayerModel
from apps.players.models.ddo import PlayerDDO
from apps.players.service.dto import PlayerOutputDTO, UpdatePlayerInputDTO
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
