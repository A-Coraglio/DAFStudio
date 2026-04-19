"""Matchmaking algorithm.

Runs one pass across all sports. For each sport, groups compatible waiting
tickets by pairwise constraints (geo, ranking, time window), creates a
pending-acceptance game for each filled group, and flips the tickets to
'proposed' so the participants enter the accept/reject phase.
"""
from dataclasses import dataclass
from datetime import datetime, timezone
from math import asin, cos, radians, sin, sqrt

from apps.courts.models.models import CourtModel
from apps.courts.models.ddo import CourtDDO
from apps.games.models.game_player import GamePlayerModel
from apps.games.models.models import GamesModel
from apps.matchmaking.models.ddo import MatchmakingTicketDDO
from apps.matchmaking.models.models import MatchmakingTicketModel
from apps.players.models.models import PlayerModel
from apps.sports.models.models import SportModel
from apps.sports.models.ddo import SportDDO


# Ranking tolerance starts narrow and expands every 30s so long-waiting
# tickets eventually match even when the pool is thin. Mirrors CS2/LoL.
_RANKING_BASE = 50
_RANKING_STEP = 50
_RANKING_STEP_SECONDS = 30
_RANKING_CAP = 2000


def ranking_tolerance(ticket_age_seconds: float) -> int:
    steps = int(ticket_age_seconds // _RANKING_STEP_SECONDS)
    return min(_RANKING_CAP, _RANKING_BASE + steps * _RANKING_STEP)


def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2) ** 2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2) ** 2
    return 2 * R * asin(sqrt(a))


def _windows_overlap(t1: MatchmakingTicketDDO, t2: MatchmakingTicketDDO) -> bool:
    return not (t1.window_end < t2.window_start or t2.window_end < t1.window_start)


@dataclass
class _TicketCtx:
    """A ticket plus precomputed data used by the greedy grouping loop."""
    ticket: MatchmakingTicketDDO
    ranking: int
    age_seconds: float

    @property
    def tolerance(self) -> int:
        return ranking_tolerance(self.age_seconds)


def _tickets_compatible(a: _TicketCtx, b: _TicketCtx) -> bool:
    # Radii must overlap (the two players could share some meeting point).
    distance = haversine_km(
        a.ticket.origin_lat, a.ticket.origin_lon,
        b.ticket.origin_lat, b.ticket.origin_lon,
    )
    if distance > a.ticket.max_radius_km + b.ticket.max_radius_km:
        return False

    # Time windows must overlap.
    if not _windows_overlap(a.ticket, b.ticket):
        return False

    # Ranking proximity: the stricter of the two tolerances must accept the
    # gap. Prevents a very-patient high-elo player dragging beginners in.
    allowed = min(a.tolerance, b.tolerance)
    if abs(a.ranking - b.ranking) > allowed:
        return False

    return True


def _form_groups(
    tickets: list[_TicketCtx], group_size: int
) -> list[list[_TicketCtx]]:
    """Greedy pairwise-compatible grouping. Oldest seed first."""
    ordered = sorted(tickets, key=lambda c: c.ticket.created_at)
    used: set[int] = set()
    groups: list[list[_TicketCtx]] = []

    for seed in ordered:
        if seed.ticket.id in used:
            continue
        group: list[_TicketCtx] = [seed]
        for candidate in ordered:
            if candidate.ticket.id in used or candidate.ticket.id == seed.ticket.id:
                continue
            if all(_tickets_compatible(candidate, member) for member in group):
                group.append(candidate)
                if len(group) == group_size:
                    break
        if len(group) == group_size:
            for c in group:
                used.add(c.ticket.id)
            groups.append(group)
    return groups


def _centroid(tickets: list[MatchmakingTicketDDO]) -> tuple[float, float]:
    lat = sum(t.origin_lat for t in tickets) / len(tickets)
    lon = sum(t.origin_lon for t in tickets) / len(tickets)
    return lat, lon


def _group_name(sport: SportDDO, group: list[_TicketCtx]) -> str:
    return f"Matchmaking {sport.name} · {len(group)} jugadores"


class Matcher:
    """Stateless runner — one pass over all sports."""

    async def run(self) -> int:
        sports = await SportModel().list_sports()
        total = 0
        for sport in sports:
            total += await self._match_sport(sport)
        return total

    async def _match_sport(self, sport: SportDDO) -> int:
        group_size = 2 * max(1, sport.max_players_per_team)
        tickets = await MatchmakingTicketModel().list_waiting_for_sport(
            sport_id=sport.id
        )
        if len(tickets) < group_size:
            return 0

        # Preload player ranking for each ticket-owner in one query.
        players = await PlayerModel().list_players_by_user_ids(
            [t.user_id for t in tickets]
        )
        ranking_by_user = {p.user_id: p.ranking_points for p in players}

        now = datetime.now(timezone.utc)
        ctxs: list[_TicketCtx] = []
        for t in tickets:
            created = t.created_at
            # asyncpg gives us a naive datetime; treat it as UTC if it has no tz.
            if created.tzinfo is None:
                created = created.replace(tzinfo=timezone.utc)
            ctxs.append(_TicketCtx(
                ticket=t,
                ranking=ranking_by_user.get(t.user_id, 0),
                age_seconds=(now - created).total_seconds(),
            ))

        groups = _form_groups(ctxs, group_size)
        for group in groups:
            await self._finalize_group(sport, group)
        return len(groups)

    async def _finalize_group(
        self, sport: SportDDO, group: list[_TicketCtx]
    ) -> None:
        tickets = [c.ticket for c in group]
        centroid_lat, centroid_lon = _centroid(tickets)

        # Pick a venue near the centroid. Use the first organizer as the
        # "current_user" so list_courts' visibility filter accepts public
        # club courts (private courts are excluded by sport filter because
        # we also want a club court, so visibility doesn't matter much).
        venue = await self._pick_venue(
            sport_id=sport.id,
            organizer_user_id=tickets[0].user_id,
            centroid_lat=centroid_lat,
            centroid_lon=centroid_lon,
        )

        # The game is created in pending_acceptance — participants must each
        # accept/reject before it becomes playable.
        organizer_id = tickets[0].user_id
        earliest_start = max(t.window_start for t in tickets)
        game = await GamesModel().create_game(
            name=_group_name(sport, group),
            sport_id=sport.id,
            max_players=len(tickets),
            organizer_id=organizer_id,
            mode="matchmaking",
            level=None,
            court_id=venue.id if venue else None,
            scheduled_at=earliest_start,
        )
        await GamesModel().update_game(game_id=game.id, status="pending_acceptance")

        # Link players to the game and flip tickets to 'proposed'.
        for ctx in group:
            player = await PlayerModel().get_player_by_user_id(
                user_id=ctx.ticket.user_id
            )
            if player is None:
                continue
            await GamePlayerModel().add_player(
                game_id=game.id, player_id=player.id
            )
            await MatchmakingTicketModel().set_status(
                ticket_id=ctx.ticket.id,
                status="proposed",
                matched_game_id=game.id,
            )

    async def _pick_venue(
        self,
        sport_id: int,
        organizer_user_id: int,
        centroid_lat: float,
        centroid_lon: float,
    ) -> CourtDDO | None:
        candidates = await CourtModel().list_courts(
            current_user_id=organizer_user_id,
            sport_id=sport_id,
            near_lat=centroid_lat,
            near_lon=centroid_lon,
            radius_km=50.0,
        )
        # Only public club courts are valid for matchmaking — never someone's
        # private backyard. First result is the closest due to ORDER BY.
        for c in candidates:
            if c.club_id is not None:
                return c
        return None
