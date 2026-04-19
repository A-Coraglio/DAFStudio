from fastapi import APIRouter, Depends

from apps.matchmaking.service.dto import (
    QueueInputDTO,
    TicketOutputDTO,
    StatusOutputDTO,
    RunMatcherOutputDTO,
)
from apps.matchmaking.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.post("/matchmaking/queue/", responses={
    200: {"model": TicketOutputDTO, "description": "Ticket created (and possibly already proposed)"},
    401: {"description": "Unauthorized"},
    409: {"description": "User already has an active ticket"},
})
async def queue(
    body: QueueInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().queue(data=body, current_user_id=current_user_id)


@router.delete("/matchmaking/queue/", responses={
    200: {"model": TicketOutputDTO, "description": "Ticket cancelled"},
    401: {"description": "Unauthorized"},
    404: {"description": "No active ticket"},
})
async def cancel(current_user_id: int = Depends(get_current_user_id)):
    return await AppService().cancel(current_user_id=current_user_id)


@router.get("/matchmaking/status/", responses={
    200: {
        "model": StatusOutputDTO,
        "description": "Active ticket (if any) plus proposed game when in acceptance phase",
    },
    401: {"description": "Unauthorized"},
})
async def status(current_user_id: int = Depends(get_current_user_id)):
    return await AppService().status(current_user_id=current_user_id)


@router.post("/matchmaking/tickets/{ticket_id}/accept/", responses={
    200: {"model": StatusOutputDTO, "description": "Accepted; game becomes full when all participants accept"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not your ticket"},
    404: {"description": "Ticket not found"},
    409: {"description": "Ticket is not in 'proposed' state"},
})
async def accept(
    ticket_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().accept(
        ticket_id=ticket_id, current_user_id=current_user_id
    )


@router.post("/matchmaking/tickets/{ticket_id}/reject/", responses={
    200: {"model": TicketOutputDTO, "description": "Rejected; group is dissolved and other participants go back to 'waiting'"},
    401: {"description": "Unauthorized"},
    403: {"description": "Not your ticket"},
    404: {"description": "Ticket not found"},
    409: {"description": "Ticket is not in an acceptance state"},
})
async def reject(
    ticket_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().reject(
        ticket_id=ticket_id, current_user_id=current_user_id
    )


@router.post("/matchmaking/run/", responses={
    200: {"model": RunMatcherOutputDTO, "description": "Matcher ran, returns matches created"},
    401: {"description": "Unauthorized"},
})
async def run_matcher(current_user_id: int = Depends(get_current_user_id)):
    """Manually trigger one pass of the matcher. Useful during development
    and as the entry point for a future scheduled job."""
    return await AppService().run_matcher()
