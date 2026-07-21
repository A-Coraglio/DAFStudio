"""Seed script: fills games (played + joinable) and chats so the app looks
lived-in for demos/testing.

Idempotent — guarded by name / composite key, safe to run repeatedly:

    cd backend
    ./venv/Scripts/python.exe seed_games_chats.py

Resolves accounts by username so it survives DB resets: "agustin" and
"rival" are the real test accounts; the profe_* seed accounts (from
database-model/seeds/tournaments_classes.sql) act as opponents.
"""
import asyncio
import os
from datetime import datetime, timedelta

import asyncpg
from dotenv import load_dotenv

load_dotenv()

# Reference "now" for the seed (project date). Past = played, future = joinable.
NOW = datetime(2026, 7, 16, 12, 0, 0)


async def _resolve(conn):
    sports = {r["name"]: r["id"] for r in await conn.fetch("SELECT id, name FROM sports")}
    rows = await conn.fetch(
        "SELECT u.id AS user_id, u.username, p.id AS player_id "
        "FROM auth_user u LEFT JOIN player p ON p.user_id = u.id"
    )
    users = {r["username"]: r["user_id"] for r in rows}
    players = {r["username"]: r["player_id"] for r in rows}
    return sports, users, players


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
    """Adds participants in order with a position (slot = join index, so the
    first half lands on the home side — same split as join order). created_at
    also increments per player so legacy join-order logic stays deterministic.
    Re-running the seed backfills positions on rows that predate them."""
    for i, pid in enumerate(player_ids):
        exists = await conn.fetchval(
            "SELECT 1 FROM game_player WHERE game_id = $1 AND player_id = $2",
            game_id, pid,
        )
        if exists:
            await conn.execute(
                "UPDATE game_player SET position = $3 "
                "WHERE game_id = $1 AND player_id = $2 AND position IS NULL "
                "AND NOT EXISTS (SELECT 1 FROM game_player t "
                "WHERE t.game_id = $1 AND t.position = $3)",
                game_id, pid, i,
            )
            continue
        await conn.execute(
            "INSERT INTO game_player (game_id, player_id, position, created_at) "
            "VALUES ($1, $2, $3, $4)",
            game_id, pid, i, base_time + timedelta(seconds=i),
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
        sports, users, players = await _resolve(conn)
        padel = sports.get("Pádel")
        tenis = sports.get("Tenis")
        f5 = sports.get("Fútbol 5")
        voley = sports.get("Vóley")

        # Real accounts + teacher opponents, resolved by username.
        u_me1, u_me2 = users.get("agustin"), users.get("rival")
        me1, me2 = players.get("agustin"), players.get("rival")
        ana, bruno = players.get("profe_ana"), players.get("profe_bruno")
        carla, diego = players.get("profe_carla"), players.get("profe_diego")
        u_ana, u_bruno = users.get("profe_ana"), users.get("profe_bruno")
        u_carla, u_diego = users.get("profe_carla"), users.get("profe_diego")
        if not (me1 and me2 and ana and bruno):
            print("Faltan players base (agustin/rival/profe_ana/profe_bruno). Abortando.")
            return

        # Give the real accounts a home so distance-based features look real.
        # (Ranking lives only in player_sport_stat, seeded further down.)
        for uid in (u_me1, u_me2):
            await conn.execute(
                "UPDATE auth_user SET home_lat = COALESCE(home_lat, -34.603), "
                "home_lon = COALESCE(home_lon, -58.381) WHERE id = $1", uid,
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
        for name, sport, court, mode, level, rh, ra, game_players, days_ago in played:
            gid = await _get_or_create_game(
                conn, name,
                organizer_id=u_me1, sport_id=sport, court_id=court, max_players=4,
                level=level, status="finished", mode=mode,
                scheduled_at=NOW - timedelta(days=days_ago),
                result_home=rh, result_away=ra,
                created_at=NOW - timedelta(days=days_ago, hours=1),
            )
            await _add_players(conn, gid, [p for p in game_players if p],
                               NOW - timedelta(days=days_ago, hours=1))

        # --- Open games (joinable — current user NOT in them) ----------------
        # organizer + participants are teachers; room left so you can join.
        openg = [
            ("Pádel domingo AM", padel, court_padel, "casual", "intermediate", 4,
             u_ana, [ana], 4),
            ("Buscamos un 4to", padel, court_padel, "competitive", "intermediate", 4,
             u_bruno, [ana, carla, diego], 3),      # 3/4 — one spot left
            ("Tenis singles", tenis, court_tenis, "competitive", "advanced", 2,
             u_bruno, [bruno], 5),
            ("Fútbol 5 nocturno", f5, None, "casual", None, 10,
             u_diego, [diego, ana, bruno], 2),
            ("Pádel competitivo", padel, court_padel, "competitive", "advanced", 4,
             u_carla, [carla, bruno], 6),
            ("Vóley amistoso", voley, None, "casual", None, 12,
             u_ana, [ana, bruno, carla], 7),
        ]
        for name, sport, court, mode, level, mx, organizer, game_players, days_ahead in openg:
            if sport is None or organizer is None:
                continue
            gid = await _get_or_create_game(
                conn, name,
                organizer_id=organizer, sport_id=sport, court_id=court,
                max_players=mx, level=level, status="open", mode=mode,
                scheduled_at=NOW + timedelta(days=days_ahead),
                created_at=NOW - timedelta(days=1),
            )
            await _add_players(conn, gid, [p for p in game_players if p],
                               NOW - timedelta(days=1))

        # --- Chats -----------------------------------------------------------
        # Group chat (both agus accounts + teachers).
        c1 = await _get_or_create_chat(conn, "Grupo Pádel CABA",
                                       created_at=NOW - timedelta(days=3))
        await _add_participants(conn, c1, [u_me1, u_me2, u_ana, u_bruno, u_carla])
        await _add_messages(conn, c1, [
            (u_ana, "Buenas! ¿Quién se prende el domingo?"),
            (u_me1, "Yo me sumo 🙌"),
            (u_bruno, "Va, llevo pelotas nuevas"),
            (u_carla, "Reservo la Cancha 1 entonces"),
            (u_ana, "Genial, 10 am ahí"),
        ], NOW - timedelta(days=1, hours=2))

        # Game chat tied to a played game.
        gid_sab = await conn.fetchval("SELECT id FROM game WHERE name = 'Pádel del sábado'")
        c2 = await _get_or_create_chat(conn, "Pádel del sábado", game_id=gid_sab,
                                       created_at=NOW - timedelta(days=10))
        await _add_participants(conn, c2, [u_me1, u_me2, u_ana, u_bruno])
        await _add_messages(conn, c2, [
            (u_me1, "Gran partido el del sábado 💪"),
            (u_ana, "Sí! La próxima la ganamos nosotros jaja"),
            (u_bruno, "Revancha cuando quieran"),
        ], NOW - timedelta(days=9))

        # DM-style chat (current user + Ana).
        c3 = await _get_or_create_chat(conn, "Clases con Ana",
                                       created_at=NOW - timedelta(days=2))
        await _add_participants(conn, c3, [u_me1, u_ana])
        await _add_messages(conn, c3, [
            (u_me1, "Hola Ana, ¿tenés lugar para una clase esta semana?"),
            (u_ana, "Hola! Sí, el jueves 18hs tengo disponible"),
            (u_me1, "Perfecto, agendame 🙏"),
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

        # Tournament participants — half-full brackets so cards show progress.
        tournaments = {
            r["name"]: r["id"]
            for r in await conn.fetch("SELECT id, name FROM tournament")
        }
        signups = [
            ("Abierto de Pádel CABA", [me1, me2, ana, carla]),
            ("Copa Pádel Norte", [ana, carla]),
            ("Torneo Tenis Primavera", [me2, bruno]),
            ("Liga Fútbol 5", [diego, me1]),
        ]
        for tname, pids in signups:
            tid = tournaments.get(tname)
            if not tid:
                continue
            for pid in pids:
                if pid:
                    await conn.execute(
                        "INSERT INTO tournament_participant (tournament_id, player_id) "
                        "VALUES ($1, $2) ON CONFLICT DO NOTHING",
                        tid, pid,
                    )

        # Lessons — one done, one upcoming, so "mis clases" has history.
        teachers = {
            r["username"]: r["id"]
            for r in await conn.fetch(
                "SELECT u.username, t.id FROM teacher t JOIN auth_user u ON u.id = t.user_id"
            )
        }
        lessons = [
            (teachers.get("profe_ana"), me1, NOW - timedelta(days=5, hours=-18),
             "completed", 8000),
            (teachers.get("profe_ana"), me1, NOW + timedelta(days=1, hours=6),
             "confirmed", 8000),
            (teachers.get("profe_bruno"), me2, NOW + timedelta(days=3, hours=5),
             "confirmed", 10000),
        ]
        for tid, pid, start, status, price in lessons:
            if not (tid and pid):
                continue
            exists = await conn.fetchval(
                "SELECT 1 FROM lesson WHERE teacher_id = $1 AND student_id = $2 "
                "AND start_time = $3", tid, pid, start,
            )
            if not exists:
                await conn.execute(
                    "INSERT INTO lesson (teacher_id, student_id, start_time, end_time, "
                    "status, total_price) VALUES ($1, $2, $3, $4, $5, $6)",
                    tid, pid, start, start + timedelta(hours=1), status, price,
                )

        # Counts.
        g = await conn.fetchval("SELECT count(*) FROM game")
        gp = await conn.fetchval("SELECT count(*) FROM game_player")
        ch = await conn.fetchval("SELECT count(*) FROM chat")
        cm = await conn.fetchval("SELECT count(*) FROM chat_message")
        tp = await conn.fetchval("SELECT count(*) FROM tournament_participant")
        ls = await conn.fetchval("SELECT count(*) FROM lesson")
        print(f"OK — games={g}, game_players={gp}, chats={ch}, messages={cm}, "
              f"tournament_participants={tp}, lessons={ls}")
    finally:
        await conn.close()


if __name__ == "__main__":
    asyncio.run(main())
