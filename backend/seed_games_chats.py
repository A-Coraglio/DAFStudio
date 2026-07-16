"""Seed script: fills games (played + joinable) and chats so the app looks
lived-in for demos/testing.

Idempotent — guarded by name / composite key, safe to run repeatedly:

    cd backend
    ./venv/Scripts/python.exe seed_games_chats.py

Targets the two real "agus" test accounts (users 5 and 6 → players 1 and 2)
so whichever one you're logged into shows history, stats and chats. The seed
teacher accounts (users 7-10 → players 3-6) act as opponents / other players.
"""
import asyncio
import os
from datetime import datetime, timedelta

import asyncpg
from dotenv import load_dotenv

load_dotenv()

# Reference "now" for the seed (project date). Past = played, future = joinable.
NOW = datetime(2026, 7, 15, 12, 0, 0)


async def _resolve(conn):
    sports = {r["name"]: r["id"] for r in await conn.fetch("SELECT id, name FROM sports")}
    player_by_user = {
        r["user_id"]: r["id"] for r in await conn.fetch("SELECT id, user_id FROM player")
    }
    return sports, player_by_user


async def _get_or_create_court(conn, name, sport_id, lat, lon, indoor, price):
    row = await conn.fetchrow("SELECT id FROM court WHERE name = $1", name)
    if row:
        return row["id"]
    club_id = await conn.fetchval("SELECT id FROM club WHERE name = 'Club Central'")
    return await conn.fetchval(
        "INSERT INTO court (club_id, sport_id, name, price_per_hour, is_indoor, lat, lon) "
        "VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id",
        club_id, sport_id, name, price, indoor, lat, lon,
    )


async def _get_or_create_game(conn, name, **fields):
    row = await conn.fetchrow("SELECT id FROM game WHERE name = $1", name)
    if row:
        return row["id"]
    fields = {"name": name, **fields}
    cols = ", ".join(fields)
    ph = ", ".join(f"${i + 1}" for i in range(len(fields)))
    return await conn.fetchval(
        f"INSERT INTO game ({cols}) VALUES ({ph}) RETURNING id", *fields.values()
    )


async def _add_players(conn, game_id, player_ids, base_time):
    """Adds participants in order; created_at increments per player so the
    backend's join-order team split (first half = home) is deterministic."""
    for i, pid in enumerate(player_ids):
        exists = await conn.fetchval(
            "SELECT 1 FROM game_player WHERE game_id = $1 AND player_id = $2",
            game_id, pid,
        )
        if exists:
            continue
        await conn.execute(
            "INSERT INTO game_player (game_id, player_id, created_at) VALUES ($1, $2, $3)",
            game_id, pid, base_time + timedelta(seconds=i),
        )


async def _get_or_create_chat(conn, name, game_id=None, created_at=None):
    row = await conn.fetchrow("SELECT id FROM chat WHERE name = $1", name)
    if row:
        return row["id"]
    return await conn.fetchval(
        "INSERT INTO chat (name, game_id, created_at) VALUES ($1, $2, $3) RETURNING id",
        name, game_id, created_at or NOW,
    )


async def _add_participants(conn, chat_id, user_ids):
    for uid in user_ids:
        exists = await conn.fetchval(
            "SELECT 1 FROM chat_participant WHERE chat_id = $1 AND user_id = $2",
            chat_id, uid,
        )
        if not exists:
            await conn.execute(
                "INSERT INTO chat_participant (chat_id, user_id) VALUES ($1, $2)",
                chat_id, uid,
            )


async def _add_messages(conn, chat_id, messages, base_time):
    """messages: list of (user_id, content). Only seeds if the chat has none."""
    has = await conn.fetchval("SELECT 1 FROM chat_message WHERE chat_id = $1", chat_id)
    if has:
        return
    for i, (uid, content) in enumerate(messages):
        await conn.execute(
            "INSERT INTO chat_message (chat_id, user_id, content, created_at) "
            "VALUES ($1, $2, $3, $4)",
            chat_id, uid, content, base_time + timedelta(minutes=i),
        )


async def main():
    conn = await asyncpg.connect(
        host=os.environ.get("DB_HOST"), port=os.environ.get("DB_PORT"),
        user=os.environ.get("DB_USER"), password=os.environ.get("DB_PASS"),
        database=os.environ.get("DB_NAME"),
    )
    try:
        sports, pbu = await _resolve(conn)
        padel = sports.get("Pádel")
        tenis = sports.get("Tenis")
        f5 = sports.get("Fútbol 5")
        voley = sports.get("Vóley")

        # Current-user players (both agus accounts) + teacher opponents.
        me1, me2 = pbu.get(5), pbu.get(6)
        ana, bruno, carla, diego = pbu.get(7), pbu.get(8), pbu.get(9), pbu.get(10)
        if not (me1 and me2 and ana and bruno):
            print("Faltan players base (users 5/6/7/8). Abortando.")
            return

        # Give the agus accounts a home + a non-zero ranking so profiles look real.
        for uid in (5, 6):
            await conn.execute(
                "UPDATE auth_user SET home_lat = COALESCE(home_lat, -34.603), "
                "home_lon = COALESCE(home_lon, -58.381) WHERE id = $1", uid,
            )
        for pid in (me1, me2):
            await conn.execute(
                "UPDATE player SET ranking_points = 1050 WHERE id = $1 AND ranking_points = 0",
                pid,
            )

        # Courts near CABA (for feed distance).
        court_padel = await _get_or_create_court(
            conn, "Cancha 1 (Pádel)", padel, -34.603, -58.381, True, 5000)
        court_tenis = await _get_or_create_court(
            conn, "Cancha 2 (Tenis)", tenis, -34.604, -58.382, False, 4000)

        # --- Played games (finished, with results) — history + stats ---------
        # home = [me1, me2] (first half), away = 2 teachers. Result decides W/L.
        played = [
            ("Pádel del sábado", padel, court_padel, "competitive", "intermediate",
             6, 3, [me1, me2, ana, bruno], 10),   # won
            ("Revancha de pádel", padel, court_padel, "competitive", "intermediate",
             6, 4, [me1, me2, carla, diego], 8),   # won
            ("Tenis en dobles", tenis, court_tenis, "competitive", "intermediate",
             4, 6, [me1, me2, ana, bruno], 6),      # lost
            ("Partidazo del finde", padel, court_padel, "competitive", "advanced",
             5, 5, [me1, me2, carla, diego], 4),    # draw
            ("Picadito casual", f5, None, "casual", None,
             6, 2, [me1, me2, ana, bruno], 12),     # casual (no W/L impact)
        ]
        for name, sport, court, mode, level, rh, ra, players, days_ago in played:
            gid = await _get_or_create_game(
                conn, name,
                organizer_id=6, sport_id=sport, court_id=court, max_players=4,
                level=level, status="finished", mode=mode,
                scheduled_at=NOW - timedelta(days=days_ago),
                result_home=rh, result_away=ra,
                created_at=NOW - timedelta(days=days_ago, hours=1),
            )
            await _add_players(conn, gid, [p for p in players if p],
                               NOW - timedelta(days=days_ago, hours=1))

        # --- Open games (joinable — current user NOT in them) ----------------
        # organizer + participants are teachers; room left so you can join.
        openg = [
            ("Pádel domingo AM", padel, court_padel, "casual", "intermediate", 4,
             7, [ana], 4),
            ("Buscamos un 4to", padel, court_padel, "competitive", "intermediate", 4,
             8, [ana, carla, diego], 3),      # 3/4 — one spot left
            ("Tenis singles", tenis, court_tenis, "competitive", "advanced", 2,
             8, [bruno], 5),
            ("Fútbol 5 nocturno", f5, None, "casual", None, 10,
             10, [diego, ana, bruno], 2),
            ("Pádel competitivo", padel, court_padel, "competitive", "advanced", 4,
             9, [carla, bruno], 6),
            ("Vóley amistoso", voley, None, "casual", None, 12,
             7, [ana, bruno, carla], 7),
        ]
        for name, sport, court, mode, level, mx, organizer, players, days_ahead in openg:
            if sport is None:
                continue
            gid = await _get_or_create_game(
                conn, name,
                organizer_id=organizer, sport_id=sport, court_id=court,
                max_players=mx, level=level, status="open", mode=mode,
                scheduled_at=NOW + timedelta(days=days_ahead),
                created_at=NOW - timedelta(days=1),
            )
            await _add_players(conn, gid, [p for p in players if p],
                               NOW - timedelta(days=1))

        # --- Chats -----------------------------------------------------------
        # Group chat (both agus accounts + teachers).
        c1 = await _get_or_create_chat(conn, "Grupo Pádel CABA",
                                       created_at=NOW - timedelta(days=3))
        await _add_participants(conn, c1, [5, 6, 7, 8, 9])
        await _add_messages(conn, c1, [
            (7, "Buenas! ¿Quién se prende el domingo?"),
            (6, "Yo me sumo 🙌"),
            (8, "Va, llevo pelotas nuevas"),
            (9, "Reservo la Cancha 1 entonces"),
            (7, "Genial, 10 am ahí"),
        ], NOW - timedelta(days=1, hours=2))

        # Game chat tied to a played game.
        gid_sab = await conn.fetchval("SELECT id FROM game WHERE name = 'Pádel del sábado'")
        c2 = await _get_or_create_chat(conn, "Pádel del sábado", game_id=gid_sab,
                                       created_at=NOW - timedelta(days=10))
        await _add_participants(conn, c2, [5, 6, 7, 8])
        await _add_messages(conn, c2, [
            (6, "Gran partido el del sábado 💪"),
            (7, "Sí! La próxima la ganamos nosotros jaja"),
            (8, "Revancha cuando quieran"),
        ], NOW - timedelta(days=9))

        # DM-style chat (current user + Ana).
        c3 = await _get_or_create_chat(conn, "Clases con Ana",
                                       created_at=NOW - timedelta(days=2))
        await _add_participants(conn, c3, [6, 7])
        await _add_messages(conn, c3, [
            (6, "Hola Ana, ¿tenés lugar para una clase esta semana?"),
            (7, "Hola! Sí, el jueves 18hs tengo disponible"),
            (6, "Perfecto, agendame 🙏"),
        ], NOW - timedelta(hours=6))

        # Per-sport rankings, so the profile shows different points by sport.
        # DO NOTHING keeps any value ELO may have already computed.
        sport_rankings = [
            (me2, padel, 1120), (me2, tenis, 960),
            (me1, padel, 1080), (me1, tenis, 990),
            (ana, padel, 1180), (carla, padel, 1040),
            (bruno, tenis, 1150), (diego, f5, 1090),
        ]
        for pid, sid, rp in sport_rankings:
            if pid and sid:
                await conn.execute(
                    "INSERT INTO player_sport_stat (player_id, sport_id, ranking_points) "
                    "VALUES ($1, $2, $3) ON CONFLICT (player_id, sport_id) DO NOTHING",
                    pid, sid, rp,
                )

        # Counts.
        g = await conn.fetchval("SELECT count(*) FROM game")
        gp = await conn.fetchval("SELECT count(*) FROM game_player")
        ch = await conn.fetchval("SELECT count(*) FROM chat")
        cm = await conn.fetchval("SELECT count(*) FROM chat_message")
        print(f"OK — games={g}, game_players={gp}, chats={ch}, messages={cm}")
    finally:
        await conn.close()


if __name__ == "__main__":
    asyncio.run(main())
