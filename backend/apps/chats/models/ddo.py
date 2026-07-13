from datetime import datetime
from pydantic import BaseModel, Field


class ChatDDO(BaseModel):
    id: int
    game_id: int | None = Field(default=None)
    name: str | None = Field(default=None)
    created_at: datetime
    # Populated only by list_for_user (JOIN + LATERAL); defaults elsewhere.
    game_name: str | None = Field(default=None)
    last_message: str | None = Field(default=None)
    last_message_at: datetime | None = Field(default=None)
    unread_count: int = Field(default=0)


class ChatMessageDDO(BaseModel):
    id: int
    chat_id: int
    user_id: int
    content: str
    created_at: datetime
    # Enriched by list_for_chat's JOINs; None on INSERT ... RETURNING rows.
    author_name: str | None = None
    author_player_id: int | None = None


class ChatParticipantDDO(BaseModel):
    chat_id: int
    user_id: int
