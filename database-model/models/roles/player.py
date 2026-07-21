from sqlmodel import SQLModel, Field

class Player(SQLModel, table=True):
    __tablename__ = "player" # type: ignore
    id: int = Field(primary_key=True)
    user_id: int = Field(foreign_key="auth_user.id", unique=True)
    # Display identity: the user fills these in after registering, in the
    # "complete profile" onboarding step.
    first_name: str | None = Field(max_length=50, default=None)
    last_name: str | None = Field(max_length=50, default=None)
    level: str | None = Field(max_length=20, default=None)  # "beginner", "intermediate", "advanced"
    # Ranking vive SOLO en player_sport_stat (ELO por deporte). El overall
    # legacy `ranking_points` se droppeó el 2026-07-21 (b9c0d1e2f3a4).
    favorite_sport_id: int | None = Field(foreign_key="sports.id", default=None)
    # Relative path under the backend's static `/uploads/` mount. Null when
    # the user hasn't set an avatar. Stored as path-not-URL so the backend
    # can switch storage backends without a migration.
    avatar_path: str | None = Field(max_length=255, default=None)
