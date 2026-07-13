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
    # Enriched fields — set by the chat list endpoint, defaults on single-chat
    # responses (get_chat / create / ensure_chat_for_game).
    game_name: str | None = None
    last_message: str | None = None
    last_message_at: str | None = None
    unread_count: int = 0


class MessageCreateInputDTO(BaseModel):
    content: str = Field(min_length=1, max_length=2000)


class MessageUpdateInputDTO(BaseModel):
    content: str = Field(min_length=1, max_length=2000)


class MessageOutputDTO(BaseModel):
    id: int
    chat_id: int
    user_id: int
    content: str
    created_at: str
    # Present once the author edited the message — the UI shows "editado".
    updated_at: str | None = None
    # Who wrote it — real name when the user has a player profile, username
    # otherwise. player_id lets the UI link to the public profile.
    author_name: str | None = None
    author_player_id: int | None = None
