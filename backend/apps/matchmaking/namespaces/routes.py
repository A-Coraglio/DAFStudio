from fastapi import APIRouter, Depends

from apps.matchmaking.service.dto import (
    QueueInputDTO,
    TicketOutputDTO,
    StatusOutputDTO,
)
from apps.matchmaking.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id
from apps.common.rate_limit import rate_limit

router: APIRouter = APIRouter(prefix="/api")

# Queueing runs a full matcher pass inline — cheap to abuse without a cap.
_queue_limiter = rate_limit(max_calls=6, per_seconds=60)


@router.post("/matchmaking/queue/", dependencies=[Depends(_queue_limiter)], responses={
    200: {"model": TicketOutputDTO, "description": "Ticket created (and possibly already proposed)"},
    401: {"description": "Unauthorized"},
    409: {"description": "User already has an active ticket"},
    429: {"description": "Too many attempts"},
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
