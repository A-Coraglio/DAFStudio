from pydantic import BaseModel, Field

from apps.games.service.dto import GamesOutputDTO


class PlayerOutputDTO(BaseModel):
    id: int = Field(description="The player id")
    user_id: int = Field(description="FK to auth_user")
    first_name: str | None = Field(default=None)
    last_name: str | None = Field(default=None)
    level: str | None = Field(default=None, description="beginner, intermediate, advanced")
    ranking_points: int = Field(description="ELO-like ranking (visible)")
    favorite_sport_id: int | None = Field(default=None)
    avatar_url: str | None = Field(
        default=None,
        description="Absolute URL for the avatar image, or null if unset",
    )


class UpdatePlayerInputDTO(BaseModel):
    first_name: str | None = Field(default=None)
    last_name: str | None = Field(default=None)
    level: str | None = Field(default=None)
    favorite_sport_id: int | None = Field(default=None)


class MyGameOutputDTO(GamesOutputDTO):
    """A game from the perspective of the current player: same payload as the
    games feed, plus the player's resolved outcome and team side for that
    specific game."""
    outcome: str = Field(
        description="won / lost / draw / pending (no final result yet)"
    )
    team_side: str | None = Field(
        default=None, description="home / away — null for solo / unsplittable games",
    )


class PlayerStatsOutputDTO(BaseModel):
    """Aggregate stats for the current player. Only `finished` games with a
    final result contribute to W/L/D; cancelled and result-less finished games
    are not counted."""
    ranking_points: int
    total_played: int = Field(description="Finished games WITH a final score")
    wins: int = Field(description="Competitive wins")
    losses: int = Field(description="Competitive losses")
    draws: int = Field(description="Competitive draws")
    casual_played: int = Field(description="Finished casual games (no ELO impact)")
