"""Single source of truth for the home/away split of a game's roster.

Both the ELO application (games app) and the outcome shown in a player's
history (players app) MUST use this same rule — if they diverge, the W/L a
user sees stops matching the ranking points they were given.

Rule: players who picked a position occupy their side directly (first half of
the slots = home). Players without a position fill home up to half the roster
in join order, then away — which preserves the legacy join-order split for
games where nobody picked a spot.
"""


def split_home_away(game_players: list, max_players: int) -> tuple[list, list]:
    """`game_players` are GamePlayerDDO-like rows ordered by join time.
    Returns (home, away) as lists of those same rows."""
    home_slots = max_players // 2
    home = [
        gp for gp in game_players
        if gp.position is not None and gp.position < home_slots
    ]
    away = [
        gp for gp in game_players
        if gp.position is not None and gp.position >= home_slots
    ]
    mid = len(game_players) // 2
    for gp in game_players:
        if gp.position is not None:
            continue
        (home if len(home) < mid else away).append(gp)
    return home, away
