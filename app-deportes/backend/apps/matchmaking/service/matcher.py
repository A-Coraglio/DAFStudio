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

# A proposed match waits this long for *everyone* to accept before the group
# is collapsed: non-accepters → 'expired', accepters → back to 'waiting'.
# Generous (10 min) because users may queue while doing other things and
# only notice the popup when they come back to the app.
ACCEPTANCE_TIMEOUT_SECONDS = 600


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


_MODE_LABELS = {"casual": "Casual", "competitive": "Competitivo"}


def _group_name(sport: SportDDO, group: list[_TicketCtx], mode: str) -> str:
    label = _MODE_LABELS.get(mode, mode)
    return f"Matchmaking {label} · {sport.name} · {len(group)} jugadores"


class Matcher:
    """Stateless runner — one pass over all sports."""

    # Pools the matcher iterates over. Each (sport, mode) is independent — a
    # casual queuer never shares a group with a competitive one.
    _MODES = ("casual", "competitive")

    async def run(self) -> int:
        # Clean up timed-out proposals first so the expired tickets don't
        # block the users who accepted from being re-matched this same pass.
        await self.expire_stale()
        sports = await SportModel().list_sports()
        total = 0
        for sport in sports:
            for mode in self._MODES:
                total += await self._match_pool(sport, mode)
        return total

    async def expire_stale(self) -> int:
        """Collapse any group whose acceptance phase timed out. Returns the
        number of groups expired."""
        game_ids = await MatchmakingTicketModel().list_stale_game_ids(
            timeout_seconds=ACCEPTANCE_TIMEOUT_SECONDS
        )
        for game_id in game_ids:
            await GamesModel().update_game(game_id=game_id, status="cancelled")
            await MatchmakingTicketModel().expire_group(matched_game_id=game_id)
            # The proposed game had its roster pre-linked — clear it so no
            # player stays attached to a cancelled game.
            await GamePlayerModel().remove_all_for_game(game_id=game_id)
        return len(game_ids)

    async def _match_pool(self, sport: SportDDO, mode: str) -> int:
        group_size = 2 * max(1, sport.max_players_per_team)
        tickets = await MatchmakingTicketModel().list_waiting_for_sport(
            sport_id=sport.id, mode=mode,
        )
        if len(tickets) < group_size:
            return 0

        # Preload each ticket-owner's ranking IN THIS SPORT (matchmaking groups
        # players of similar skill in the sport they queued for).
        players = await PlayerModel().list_players_by_user_ids(
            [t.user_id for t in tickets]
        )
        sport_ranking = await PlayerModel().list_sport_rankings(
            sport_id=sport.id, player_ids=[p.id for p in players]
        )
        ranking_by_user = {
            p.user_id: sport_ranking.get(p.id, 1000) for p in players
        }

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
            await self._finalize_group(sport, group, mode)
        return len(groups)

    async def _finalize_group(
        self, sport: SportDDO, group: list[_TicketCtx], mode: str,
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

        # Game + ticket flips + roster happen in ONE transaction
        # (propose_group_atomic). If a concurrent matcher already grabbed any
        # of these tickets, the whole thing rolls back and returns None —
        # nothing half-built survives, so there's no teardown path here.
        organizer_id = tickets[0].user_id
        earliest_start = max(t.window_start for t in tickets)
        await MatchmakingTicketModel().propose_group_atomic(
            ticket_ids=[t.id for t in tickets],
            user_ids=[t.user_id for t in tickets],
            name=_group_name(sport, group, mode),
            sport_id=sport.id,
            max_players=len(tickets),
            organizer_id=organizer_id,
            mode=mode,
            court_id=venue.id if venue else None,
            scheduled_at=earliest_start,
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
