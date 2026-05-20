from datetime import datetime
from pydantic import BaseModel, Field


# Ticket state machine:
#   waiting    → in queue, actively looked at by the matcher.
#   proposed   → matcher found a group; this ticket must accept or reject.
#   accepted   → this player accepted; still waiting on others in the group.
#   matched    → the whole group accepted; game is live.
#   cancelled  → user cancelled the queue manually.
#   expired    → window_end passed without match, or acceptance phase timed out.
#   rejected   → user rejected the proposal; they are out of the queue.
TICKET_STATES = (
    "waiting",
    "proposed",
    "accepted",
    "matched",
    "cancelled",
    "expired",
    "rejected",
)


class MatchmakingTicketDDO(BaseModel):
    id: int = Field(description="The ticket id")
    user_id: int = Field(description="FK to auth_user")
    sport_id: int = Field(description="Sport the user wants to play")
    max_radius_km: float = Field(description="Max distance from origin they will travel")
    origin_lat: float
    origin_lon: float
    window_start: datetime = Field(description="Earliest play time")
    window_end: datetime = Field(description="Latest play time")
    mode: str = Field(default="competitive", description="casual or competitive")
    status: str = Field(default="waiting")
    matched_game_id: int | None = Field(default=None)
    created_at: datetime
    proposed_at: datetime | None = Field(default=None)
