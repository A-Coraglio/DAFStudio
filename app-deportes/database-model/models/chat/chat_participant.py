from sqlmodel import SQLModel, Field


class ChatParticipant(SQLModel, table=True):
    """Explicit participants for general chats. For game-linked chats this
    table is typically empty — membership is inferred from `game_player`
    at the appservice layer."""
    __tablename__ = "chat_participant"  # type: ignore
    chat_id: int = Field(foreign_key="chat.id", primary_key=True)
    user_id: int = Field(foreign_key="auth_user.id", primary_key=True)
