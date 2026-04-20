from apps.games.service.iso_utils import iso_utc
from apps.matchmaking.models.models import MatchmakingTicketModel
from apps.matchmaking.models.ddo import MatchmakingTicketDDO
from apps.sports.models.models import SportModel
from apps.sports.exceptions.exceptions import SportNotFoundException
from apps.matchmaking.service.dto import (
    QueueInputDTO,
    TicketOutputDTO,
    StatusOutputDTO,
    RunMatcherOutputDTO,
)
from apps.matchmaking.service.matcher import Matcher
from apps.matchmaking.exceptions.exceptions import (
    AlreadyInQueueException,
    InvalidTicketStateException,
    TicketForbiddenException,
    TicketNotFoundException,
)
from apps.games.models.models import GamesModel
from apps.games.service.appservice import AppService as GamesAppService
from apps.games.service.dto import GamesOutputDTO


class AppService:

    def _to_output_dto(self, ticket: MatchmakingTicketDDO) -> TicketOutputDTO:
        return TicketOutputDTO(
            id=ticket.id,
            user_id=ticket.user_id,
            sport_id=ticket.sport_id,
            max_radius_km=ticket.max_radius_km,
            origin_lat=ticket.origin_lat,
            origin_lon=ticket.origin_lon,
            # window_start/end are "play-time the user picked" — sent as
            # local naive from the frontend and echoed back naive so the
            # client can display exactly what was chosen. Do NOT stamp UTC.
            window_start=ticket.window_start.isoformat(),
            window_end=ticket.window_end.isoformat(),
            status=ticket.status,
            matched_game_id=ticket.matched_game_id,
            created_at=iso_utc(ticket.created_at),
            proposed_at=(
                iso_utc(ticket.proposed_at)
                if ticket.proposed_at is not None
                else None
            ),
        )

    async def queue(
        self, data: QueueInputDTO, current_user_id: int
    ) -> TicketOutputDTO:
        existing = await MatchmakingTicketModel().get_active_ticket_for_user(
            user_id=current_user_id
        )
        if existing is not None:
            raise AlreadyInQueueException()

        ticket = await MatchmakingTicketModel().create_ticket(
            user_id=current_user_id,
            sport_id=data.sport_id,
            max_radius_km=data.max_radius_km,
            origin_lat=data.origin_lat,
            origin_lon=data.origin_lon,
            window_start=data.window_start,
            window_end=data.window_end,
        )
        # Opportunistically run the matcher so a small queue matches instantly
        # without waiting for the cron. Cheap when the queue is small.
        await Matcher().run()
        # Re-fetch — the ticket may have been flipped to 'proposed'.
        ticket = await MatchmakingTicketModel().get_ticket_by_id(
            ticket_id=ticket.id
        )
        return self._to_output_dto(ticket)

    async def cancel(self, current_user_id: int) -> TicketOutputDTO:
        existing = await MatchmakingTicketModel().get_active_ticket_for_user(
            user_id=current_user_id
        )
        if existing is None:
            raise TicketNotFoundException(
                message="You have no active matchmaking ticket"
            )
        # If they're in acceptance phase already, cancelling is equivalent
        # to rejecting the proposal — collapse the group.
        if existing.status in ("proposed", "accepted"):
            return await self.reject(
                ticket_id=existing.id, current_user_id=current_user_id
            )
        updated = await MatchmakingTicketModel().set_status(
            ticket_id=existing.id, status="cancelled"
        )
        return self._to_output_dto(updated or existing)

    async def status(self, current_user_id: int) -> StatusOutputDTO:
        # Before reading the user's ticket, expire any stale proposals so
        # the caller sees 'expired' / 'waiting' instead of a frozen 'proposed'.
        await Matcher().expire_stale()
        ticket = await MatchmakingTicketModel().get_active_ticket_for_user(
            user_id=current_user_id
        )
        proposed_game: GamesOutputDTO | None = None
        if (
            ticket is not None
            and ticket.matched_game_id is not None
            and ticket.status in ("proposed", "accepted", "matched")
        ):
            proposed_game = await GamesAppService().games_getter(
                game_id=ticket.matched_game_id
            )

        eta_seconds, depth = await self._eta_for_ticket(ticket)

        return StatusOutputDTO(
            ticket=self._to_output_dto(ticket) if ticket else None,
            proposed_game=proposed_game,
            estimated_wait_seconds=eta_seconds,
            queue_depth=depth,
        )

    async def _eta_for_ticket(
        self, ticket: MatchmakingTicketDDO | None
    ) -> tuple[int | None, int | None]:
        """Coarse ETA based on queue density for the ticket's sport.

        Heuristic only. Buckets:
          - group already formable (enough waiters) → next cron sweep (~20s)
          - half-full pool                          → ~2 minutes
          - nearly empty                            → null (can't estimate)
        """
        if ticket is None or ticket.status != "waiting":
            return None, None
        try:
            sport = await SportModel().get_sport_by_id(sport_id=ticket.sport_id)
        except SportNotFoundException:
            return None, None
        group_size = 2 * max(1, sport.max_players_per_team)
        waiting = await MatchmakingTicketModel().list_waiting_for_sport(
            sport_id=ticket.sport_id
        )
        depth = len(waiting)
        if depth >= group_size:
            return 20, depth
        if depth * 2 >= group_size:
            return 120, depth
        return None, depth

    async def accept(
        self, ticket_id: int, current_user_id: int
    ) -> StatusOutputDTO:
        ticket = await MatchmakingTicketModel().get_ticket_by_id(
            ticket_id=ticket_id
        )
        if ticket.user_id != current_user_id:
            raise TicketForbiddenException()
        if ticket.status != "proposed":
            raise InvalidTicketStateException(
                message=f"Ticket is '{ticket.status}', can't accept"
            )

        updated = await MatchmakingTicketModel().set_status(
            ticket_id=ticket.id, status="accepted"
        )
        ticket = updated or ticket

        # Check if everyone in the group accepted — if so, finalize the game.
        if ticket.matched_game_id is not None:
            siblings = await MatchmakingTicketModel().list_by_game(
                matched_game_id=ticket.matched_game_id
            )
            if siblings and all(s.status == "accepted" for s in siblings):
                # All accepted → flip tickets to 'matched', game to 'full'.
                for s in siblings:
                    await MatchmakingTicketModel().set_status(
                        ticket_id=s.id, status="matched"
                    )
                await GamesModel().update_game(
                    game_id=ticket.matched_game_id, status="full"
                )

        return await self.status(current_user_id=current_user_id)

    async def reject(
        self, ticket_id: int, current_user_id: int
    ) -> TicketOutputDTO:
        ticket = await MatchmakingTicketModel().get_ticket_by_id(
            ticket_id=ticket_id
        )
        if ticket.user_id != current_user_id:
            raise TicketForbiddenException()
        if ticket.status not in ("proposed", "accepted"):
            raise InvalidTicketStateException(
                message=f"Ticket is '{ticket.status}', can't reject"
            )

        updated = await MatchmakingTicketModel().set_status(
            ticket_id=ticket.id, status="rejected"
        )

        # Tear down the group: cancel the game, put the other tickets back
        # in the queue so they can be re-matched.
        if ticket.matched_game_id is not None:
            await GamesModel().update_game(
                game_id=ticket.matched_game_id, status="cancelled"
            )
            await MatchmakingTicketModel().reopen_group(
                matched_game_id=ticket.matched_game_id
            )

        return self._to_output_dto(updated or ticket)

    async def run_matcher(self) -> RunMatcherOutputDTO:
        matches = await Matcher().run()
        return RunMatcherOutputDTO(matches_created=matches)
