from sqlmodel import SQLModel, Field


class ChatReadState(SQLModel, table=True):
    """Per-user read cursor for a chat.

    `last_read_message_id` is the id of the newest `chat_message` the user
    has seen. Unread = messages in that chat with a higher id, excluding the
    user's own. No row at all → the user never opened the chat, so every
    message counts as unread.

    Keyed by (chat_id, user_id) rather than living on `chat_participant`
    because game-linked chats have no explicit participant rows — membership
    there is inferred from `game_player`.
    """
    __tablename__ = "chat_read_state"  # type: ignore
    chat_id: int = Field(foreign_key="chat.id", primary_key=True)
    user_id: int = Field(foreign_key="auth_user.id", primary_key=True)
    last_read_message_id: int | None = Field(
        foreign_key="chat_message.id", default=None
    )
