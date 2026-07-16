-- Seed data for the `sports` catalog.
--
-- The onboarding flow (PUT /api/players/me/) and the "create game" screen show
-- a sports dropdown populated from GET /api/sports/. A fresh database has an
-- empty `sports` table, which leaves that dropdown blank and blocks the user
-- from finishing their profile. This seed fills it with the sports the Flutter
-- client already knows how to render (icons + per-sport roster sizes in
-- gohan/lib/features/games/data/sport_player_options.dart).
--
-- `max_players_per_team` is PER TEAM (a padel match = 2 per team = 4 players).
--
-- Idempotent: `sports.name` has no UNIQUE constraint, so we guard each row with
-- NOT EXISTS instead of ON CONFLICT. Safe to run repeatedly.

INSERT INTO sports (name, max_players_per_team)
SELECT v.name, v.max_players_per_team
FROM (VALUES
    ('Pádel',    2),
    ('Tenis',    2),
    ('Fútbol 5', 5),
    ('Fútbol 7', 7),
    ('Básquet',  5),
    ('Vóley',    6)
) AS v(name, max_players_per_team)
WHERE NOT EXISTS (
    SELECT 1 FROM sports s WHERE s.name = v.name
);
