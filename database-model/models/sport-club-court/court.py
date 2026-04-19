from sqlmodel import SQLModel, Field
from sqlalchemy import CheckConstraint

class Court(SQLModel, table=True):
    __tablename__ = "court" # type: ignore
    # A court belongs EITHER to a club (public, selectable by anyone) OR to a
    # user (private, only selectable by its owner). Exactly one FK must be set.
    __table_args__ = (
        CheckConstraint(
            "(club_id IS NOT NULL AND owner_id IS NULL) "
            "OR (club_id IS NULL AND owner_id IS NOT NULL)",
            name="court_club_xor_owner",
        ),
    )
    id: int = Field(primary_key=True, index=True)
    club_id: int | None = Field(foreign_key="club.id", default=None)
    owner_id: int | None = Field(foreign_key="auth_user.id", default=None)
    sport_id: int = Field(foreign_key="sports.id")
    name: str = Field(max_length=50)
    price_per_hour: float
    is_indoor: bool = False
    lat: float | None = Field(default=None)
    lon: float | None = Field(default=None)
