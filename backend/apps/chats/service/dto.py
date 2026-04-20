from pydantic import BaseModel, Field


class ChatCreateInputDTO(BaseModel):
    """Creates a general chat (not tied to a game). Pass the user_ids of
    everyone who should be a participant — the current user is added too."""
    name: str | None = Field(default=None, max_length=100)
    participant_user_ids: list[int] = Field(default_factory=list)


class ChatOutputDTO(BaseModel):
    id: int
    game_id: int | None = None
    name: str | None = None
    created_at: str


class MessageCreateInputDTO(BaseModel):
    content: str = Field(min_length=1, max_length=2000)


class MessageOutputDTO(BaseModel):
    id: int
    chat_id: int
    user_id: int
    content: str
    created_at: str
