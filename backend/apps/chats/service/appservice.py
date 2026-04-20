from apps.games.service.iso_utils import iso_utc
from apps.chats.models.models import (
    ChatModel,
    ChatParticipantModel,
    ChatMessageModel,
)
from apps.chats.models.ddo import ChatDDO, ChatMessageDDO
from apps.chats.service.dto import (
    ChatCreateInputDTO,
    ChatOutputDTO,
    MessageCreateInputDTO,
    MessageOutputDTO,
)
from apps.chats.exceptions.exceptions import (
    ChatForbiddenException,
    ChatNotFoundException,
)
from apps.games.models.game_player import GamePlayerModel
from apps.players.models.models import PlayerModel


class AppService:

    def _chat_to_dto(self, chat: ChatDDO) -> ChatOutputDTO:
        return ChatOutputDTO(
            id=chat.id,
            game_id=chat.game_id,
            name=chat.name,
            created_at=iso_utc(chat.created_at),
        )

    def _message_to_dto(self, msg: ChatMessageDDO) -> MessageOutputDTO:
        return MessageOutputDTO(
            id=msg.id,
            chat_id=msg.chat_id,
            user_id=msg.user_id,
            content=msg.content,
            created_at=iso_utc(msg.created_at),
        )

    async def _assert_can_read(
        self, chat: ChatDDO, current_user_id: int
    ) -> None:
        """Access rule:
          - game-linked chat → current user must be a game_player of that game.
          - general chat → current user must be a chat_participant.
        """
        if chat.game_id is not None:
            rows = await GamePlayerModel().list_players(game_id=chat.game_id)
            player_ids = {r.player_id for r in rows}
            if not player_ids:
                raise ChatForbiddenException()
            players = await PlayerModel().list_players_by_ids(list(player_ids))
            user_ids = {p.user_id for p in players}
            if current_user_id not in user_ids:
                raise ChatForbiddenException()
            return
        is_participant = await ChatParticipantModel().is_participant(
            chat_id=chat.id, user_id=current_user_id
        )
        if not is_participant:
            raise ChatForbiddenException()

    async def list_mine(self, current_user_id: int) -> list[ChatOutputDTO]:
        chats = await ChatModel().list_for_user(user_id=current_user_id)
        return [self._chat_to_dto(c) for c in chats]

    async def get_chat(
        self, chat_id: int, current_user_id: int
    ) -> ChatOutputDTO:
        chat = await ChatModel().get_by_id(chat_id=chat_id)
        await self._assert_can_read(chat, current_user_id)
        return self._chat_to_dto(chat)

    async def create_general(
        self, data: ChatCreateInputDTO, current_user_id: int
    ) -> ChatOutputDTO:
        chat = await ChatModel().create(game_id=None, name=data.name)
        participants = set(data.participant_user_ids) | {current_user_id}
        for uid in participants:
            await ChatParticipantModel().add(chat_id=chat.id, user_id=uid)
        return self._chat_to_dto(chat)

    async def ensure_chat_for_game(self, game_id: int) -> ChatOutputDTO:
        """Idempotent — returns the game's chat, creating it on first call.
        Used when a game is opened for the first time."""
        existing = await ChatModel().get_by_game_id(game_id=game_id)
        if existing is not None:
            return self._chat_to_dto(existing)
        chat = await ChatModel().create(game_id=game_id, name=None)
        return self._chat_to_dto(chat)

    async def list_messages(
        self,
        chat_id: int,
        current_user_id: int,
        limit: int = 50,
        before_id: int | None = None,
    ) -> list[MessageOutputDTO]:
        chat = await ChatModel().get_by_id(chat_id=chat_id)
        await self._assert_can_read(chat, current_user_id)
        msgs = await ChatMessageModel().list_for_chat(
            chat_id=chat_id, limit=limit, before_id=before_id
        )
        return [self._message_to_dto(m) for m in msgs]

    async def post_message(
        self,
        chat_id: int,
        data: MessageCreateInputDTO,
        current_user_id: int,
    ) -> MessageOutputDTO:
        chat = await ChatModel().get_by_id(chat_id=chat_id)
        await self._assert_can_read(chat, current_user_id)
        msg = await ChatMessageModel().create(
            chat_id=chat_id,
            user_id=current_user_id,
            content=data.content,
        )
        return self._message_to_dto(msg)
