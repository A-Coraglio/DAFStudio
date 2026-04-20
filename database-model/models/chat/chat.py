from datetime import datetime, timezone
from sqlmodel import SQLModel, Field
from sqlalchemy.sql import func


class Chat(SQLModel, table=True):
    """A conversation. Two flavors share the same table:

    - `game_id` NOT NULL → the chat belongs to a specific game; visible only
      from within that game's detail screen. Participants are implicit
      (everyone in game_player).
    - `game_id` NULL → "general" chat. Participants are explicit via
      `chat_participant` rows. Appears in the user's chat list alongside
      game chats but not tied to any match.

    `name` is used as the display title when `game_id` is NULL. For
    game-linked chats the frontend uses the game's own name.
    """
    __tablename__ = "chat"  # type: ignore
    id: int = Field(primary_key=True)
    game_id: int | None = Field(foreign_key="game.id", default=None, index=True)
    name: str | None = Field(max_length=100, default=None)
    created_at: datetime = Field(
        default_factory=lambda: datetime.now(timezone.utc),
        sa_column_kwargs={"server_default": func.now()},
    )
