from datetime import datetime
from pydantic import BaseModel, Field


class ChatDDO(BaseModel):
    id: int
    game_id: int | None = Field(default=None)
    name: str | None = Field(default=None)
    created_at: datetime


class ChatMessageDDO(BaseModel):
    id: int
    chat_id: int
    user_id: int
    content: str
    created_at: datetime


class ChatParticipantDDO(BaseModel):
    chat_id: int
    user_id: int
