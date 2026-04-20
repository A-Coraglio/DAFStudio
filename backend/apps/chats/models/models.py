from typing import cast

from asyncpg.pool import PoolConnectionProxy

from apps.chats.models import GeneralModel
from apps.chats.models.ddo import ChatDDO, ChatMessageDDO
from apps.chats.exceptions.exceptions import ChatNotFoundException
from apps.games.exceptions.exceptions import DatbaseException


def _row_to_chat(row) -> ChatDDO:
    return ChatDDO(
        id=row["id"],
        game_id=row["game_id"],
        name=row["name"],
        created_at=row["created_at"],
    )


def _row_to_message(row) -> ChatMessageDDO:
    return ChatMessageDDO(
        id=row["id"],
        chat_id=row["chat_id"],
        user_id=row["user_id"],
        content=row["content"],
        created_at=row["created_at"],
    )


class ChatModel(GeneralModel):
    __table_name__ = "chat"

    async def get_by_id(self, chat_id: int) -> ChatDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE id = $1"
            try:
                row = await connection.fetchrow(query, chat_id)
                if row is None:
                    raise ChatNotFoundException()
                return _row_to_chat(row)
            except ChatNotFoundException:
                raise
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def get_by_game_id(self, game_id: int) -> ChatDDO | None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = f"SELECT * FROM {self.__table_name__} WHERE game_id = $1"
            try:
                row = await connection.fetchrow(query, game_id)
                return _row_to_chat(row) if row else None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create(
        self, game_id: int | None = None, name: str | None = None
    ) -> ChatDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} (game_id, name) "
                "VALUES ($1, $2) RETURNING *"
            )
            try:
                row = await connection.fetchrow(query, game_id, name)
                return _row_to_chat(row)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def list_for_user(self, user_id: int) -> list[ChatDDO]:
        """Every chat the user can see — general chats they're listed in,
        plus game chats whose game they're joined to (via game_player)."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                "SELECT c.* FROM chat c "
                "WHERE c.id IN ( "
                "    SELECT chat_id FROM chat_participant WHERE user_id = $1 "
                ") OR c.game_id IN ( "
                "    SELECT gp.game_id FROM game_player gp "
                "    JOIN player p ON p.id = gp.player_id "
                "    WHERE p.user_id = $1 "
                ") "
                "ORDER BY c.created_at DESC"
            )
            try:
                rows = await connection.fetch(query, user_id)
                return [_row_to_chat(r) for r in rows]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")


class ChatParticipantModel(GeneralModel):
    __table_name__ = "chat_participant"

    async def add(self, chat_id: int, user_id: int) -> None:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} (chat_id, user_id) "
                "VALUES ($1, $2) ON CONFLICT DO NOTHING"
            )
            try:
                await connection.execute(query, chat_id, user_id)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def is_participant(self, chat_id: int, user_id: int) -> bool:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT 1 FROM {self.__table_name__} "
                "WHERE chat_id = $1 AND user_id = $2 LIMIT 1"
            )
            try:
                row = await connection.fetchrow(query, chat_id, user_id)
                return row is not None
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def list_user_ids(self, chat_id: int) -> list[int]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"SELECT user_id FROM {self.__table_name__} WHERE chat_id = $1"
            )
            try:
                rows = await connection.fetch(query, chat_id)
                return [r["user_id"] for r in rows]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")


class ChatMessageModel(GeneralModel):
    __table_name__ = "chat_message"

    async def list_for_chat(
        self, chat_id: int, limit: int = 50, before_id: int | None = None
    ) -> list[ChatMessageDDO]:
        """Descending by id — newest first. Use `before_id` to page backward."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            if before_id is not None:
                query = (
                    f"SELECT * FROM {self.__table_name__} "
                    "WHERE chat_id = $1 AND id < $2 "
                    "ORDER BY id DESC LIMIT $3"
                )
                values = [chat_id, before_id, limit]
            else:
                query = (
                    f"SELECT * FROM {self.__table_name__} "
                    "WHERE chat_id = $1 ORDER BY id DESC LIMIT $2"
                )
                values = [chat_id, limit]
            try:
                rows = await connection.fetch(query, *values)
                return [_row_to_message(r) for r in rows]
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")

    async def create(
        self, chat_id: int, user_id: int, content: str
    ) -> ChatMessageDDO:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"INSERT INTO {self.__table_name__} (chat_id, user_id, content) "
                "VALUES ($1, $2, $3) RETURNING *"
            )
            try:
                row = await connection.fetchrow(query, chat_id, user_id, content)
                return _row_to_message(row)
            except Exception as e:
                raise DatbaseException(message=f"Database error: {e}")
