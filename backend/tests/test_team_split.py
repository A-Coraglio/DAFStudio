"""Invariantes de split_home_away — la única regla de armado de equipos.

Correr con: cd backend && .venv/Scripts/python -m pytest
"""
import sys
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from apps.games.service.team_split import split_home_away  # noqa: E402


@dataclass
class GP:
    """GamePlayerDDO-like row: solo lo que mira el split."""
    player_id: int
    position: int | None = None


def ids(rows):
    return [gp.player_id for gp in rows]


def test_positions_respetadas():
    # 4 jugadores, todos con posición: 0-1 = home, 2-3 = away.
    players = [GP(1, 0), GP(2, 2), GP(3, 1), GP(4, 3)]
    home, away = split_home_away(players, max_players=4)
    assert ids(home) == [1, 3]
    assert ids(away) == [2, 4]


def test_sin_posiciones_cae_a_orden_de_join():
    # Nadie eligió: primera mitad por orden de join = home.
    players = [GP(1), GP(2), GP(3), GP(4)]
    home, away = split_home_away(players, max_players=4)
    assert ids(home) == [1, 2]
    assert ids(away) == [3, 4]


def test_mixto_completa_con_los_sin_posicion():
    # 1 eligió home (slot 0), 1 eligió away (slot 3); los otros dos sin
    # posición completan balanceando por orden de join.
    players = [GP(1, 0), GP(2, None), GP(3, 3), GP(4, None)]
    home, away = split_home_away(players, max_players=4)
    assert set(ids(home)) | set(ids(away)) == {1, 2, 3, 4}
    assert 1 in ids(home)
    assert 3 in ids(away)
    assert len(home) == 2 and len(away) == 2


def test_nadie_se_pierde_ni_se_duplica():
    # Roster impar con mezcla: el split siempre particiona el roster.
    players = [GP(1, 4), GP(2), GP(3, 0), GP(4), GP(5)]
    home, away = split_home_away(players, max_players=10)
    todos = ids(home) + ids(away)
    assert sorted(todos) == [1, 2, 3, 4, 5]
    assert len(set(todos)) == 5


def test_roster_vacio():
    home, away = split_home_away([], max_players=4)
    assert home == [] and away == []


def test_futbol_grande():
    # F5 (10 slots): posiciones 0-4 home, 5-9 away.
    players = [GP(i, i) for i in range(10)]
    home, away = split_home_away(players, max_players=10)
    assert ids(home) == [0, 1, 2, 3, 4]
    assert ids(away) == [5, 6, 7, 8, 9]
