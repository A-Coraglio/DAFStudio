from fastapi import APIRouter, Depends, Query

from apps.chats.service.appservice import AppService
from apps.chats.service.dto import (
    ChatOutputDTO,
    MessageCreateInputDTO,
    MessageOutputDTO,
    MessageUpdateInputDTO,
)
from apps.users.service.auth_dependency import get_current_user_id


router: APIRouter = APIRouter(prefix="/api")


@router.get(
    "/chats/",
    responses={
        200: {"model": list[ChatOutputDTO], "description": "My chats"},
        401: {"description": "Unauthorized"},
    },
)
async def list_my_chats(
    limit: int = Query(default=100, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().list_mine(
        current_user_id=current_user_id, limit=limit, offset=offset
    )


# NOTE: POST /chats/ (chats generales) fue deshabilitado el 2026-07-21: la UI
# nunca lo usó y permitía meter a cualquiera en un chat sin consentimiento.
# Revivirlo recién cuando exista el modelo social (amigos/invitaciones).


@router.get(
    "/chats/unread-count/",
    responses={
        200: {"description": "Total unread messages across the user's chats"},
        401: {"description": "Unauthorized"},
    },
)
async def get_unread_count(current_user_id: int = Depends(get_current_user_id)):
    # Declared before /chats/{chat_id}/ so "unread-count" isn't parsed as an id.
    total = await AppService().unread_total(current_user_id=current_user_id)
    return {"count": total}


@router.get(
    "/chats/{chat_id}/",
    responses={
        200: {"model": ChatOutputDTO, "description": "Chat metadata"},
        401: {"description": "Unauthorized"},
        403: {"description": "Not a participant"},
        404: {"description": "Chat not found"},
    },
)
async def get_chat(
    chat_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().get_chat(
        chat_id=chat_id, current_user_id=current_user_id
    )


@router.get(
    "/chats/{chat_id}/messages/",
    responses={
        200: {"model": list[MessageOutputDTO], "description": "Messages DESC"},
        401: {"description": "Unauthorized"},
        403: {"description": "Not a participant"},
        404: {"description": "Chat not found"},
    },
)
async def list_messages(
    chat_id: int,
    limit: int = Query(default=50, ge=1, le=200),
    before_id: int | None = None,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().list_messages(
        chat_id=chat_id,
        current_user_id=current_user_id,
        limit=limit,
        before_id=before_id,
    )


@router.post(
    "/chats/{chat_id}/messages/",
    responses={
        200: {"model": MessageOutputDTO, "description": "Created message"},
        401: {"description": "Unauthorized"},
        403: {"description": "Not a participant"},
        404: {"description": "Chat not found"},
    },
)
async def post_message(
    chat_id: int,
    body: MessageCreateInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().post_message(
        chat_id=chat_id, data=body, current_user_id=current_user_id
    )


@router.patch(
    "/chats/{chat_id}/messages/{message_id}/",
    responses={
        200: {"model": MessageOutputDTO, "description": "Updated message"},
        401: {"description": "Unauthorized"},
        403: {"description": "Not the author"},
        404: {"description": "Chat or message not found"},
    },
)
async def update_message(
    chat_id: int,
    message_id: int,
    body: MessageUpdateInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().update_message(
        chat_id=chat_id,
        message_id=message_id,
        data=body,
        current_user_id=current_user_id,
    )


@router.delete(
    "/chats/{chat_id}/messages/{message_id}/",
    responses={
        200: {"description": "Message deleted"},
        401: {"description": "Unauthorized"},
        403: {"description": "Not the author"},
        404: {"description": "Chat or message not found"},
    },
)
async def delete_message(
    chat_id: int,
    message_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    await AppService().delete_message(
        chat_id=chat_id,
        message_id=message_id,
        current_user_id=current_user_id,
    )
    return {"ok": True}


@router.post(
    "/chats/{chat_id}/read/",
    responses={
        200: {"description": "Read cursor moved to the latest message"},
        401: {"description": "Unauthorized"},
        403: {"description": "Not a participant"},
        404: {"description": "Chat not found"},
    },
)
async def mark_chat_read(
    chat_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    await AppService().mark_chat_read(
        chat_id=chat_id, current_user_id=current_user_id
    )
    return {"ok": True}


@router.get(
    "/games/{game_id}/chat/",
    responses={
        200: {
            "model": ChatOutputDTO,
            "description": "The chat for this game (auto-created if missing)",
        },
        401: {"description": "Unauthorized"},
        403: {"description": "Not a participant of this game"},
    },
)
async def get_or_create_game_chat(
    game_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().ensure_chat_for_game(
        game_id=game_id, current_user_id=current_user_id
    )
