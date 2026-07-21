-- Seed data for the Tournaments and Classes features.
--
-- Fills the home carousels (recommended tournaments / classes) and their
-- search screens with realistic data around Buenos Aires (~ -34.6, -58.4).
-- Idempotent: every row is guarded with NOT EXISTS, so it is safe to re-run.
--
-- Tournaments are organised by the FIRST real (non-seed, non-deleted) user of
-- the database — no hardcoded email, so the seed works on any machine as long
-- as one account was registered first. Dates are RELATIVE to now(), and a
-- final UPDATE re-futurizes expired seed tournaments on re-runs.
--
-- Teachers get their own seed auth_user + player (for a nice display name) +
-- teacher + teacher_sport row. Seed teacher accounts use a placeholder
-- password hash and are not meant to log in.

-- ---------------------------------------------------------------------------
-- Teacher accounts (auth_user + player + teacher + teacher_sport)
-- ---------------------------------------------------------------------------

-- Ana — Pádel
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_ana', 'ana@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.601, -58.383
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'ana@seed.local');

INSERT INTO player (user_id, first_name, last_name, level)
SELECT u.id, 'Ana', 'Gómez', 'advanced'
FROM auth_user u WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Clases de pádel para todos los niveles. Técnica y táctica.', 8000, 6
FROM auth_user u WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name = 'Pádel'
WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Bruno — Tenis
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_bruno', 'bruno@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.582, -58.421
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'bruno@seed.local');

INSERT INTO player (user_id, first_name, last_name, level)
SELECT u.id, 'Bruno', 'Fernández', 'intermediate'
FROM auth_user u WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Profe de tenis. Preparación física y saque.', 10000, 9
FROM auth_user u WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name = 'Tenis'
WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Carla — Pádel (más económica, más cerca)
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_carla', 'carla@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.615, -58.373
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'carla@seed.local');

INSERT INTO player (user_id, first_name, last_name, level)
SELECT u.id, 'Carla', 'Ruiz', 'beginner'
FROM auth_user u WHERE u.email = 'carla@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Iniciación al pádel. Clases grupales y particulares.', 7000, 3
FROM auth_user u WHERE u.email = 'carla@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name = 'Pádel'
WHERE u.email = 'carla@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Diego — Fútbol
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_diego', 'diego@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.551, -58.462
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'diego@seed.local');

INSERT INTO player (user_id, first_name, last_name, level)
SELECT u.id, 'Diego', 'López', 'intermediate'
FROM auth_user u WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Entrenador de fútbol. Fundamentos y juego de posición.', 6000, 12
FROM auth_user u WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name = 'Fútbol 5'
WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Extra sports per teacher (requires the composite teacher_sport PK). Some
-- teachers coach more than one sport. The JOIN against sports means a name
-- that doesn't exist in the catalog simply inserts nothing (no NULL FKs).
--   Ana   -> Pádel + Tenis
--   Bruno -> Tenis + Pádel
--   Diego -> Fútbol 5 + Fútbol 7 (o Fútbol 11, según el catálogo local)
INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name = 'Tenis'
WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id
                  AND ts.sport_id = s.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name = 'Pádel'
WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id
                  AND ts.sport_id = s.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, s.id
FROM teacher t
JOIN auth_user u ON u.id = t.user_id
JOIN sports s ON s.name IN ('Fútbol 7', 'Fútbol 11')
WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id
                  AND ts.sport_id = s.id);

-- ---------------------------------------------------------------------------
-- Clubs (optional host for tournaments)
-- ---------------------------------------------------------------------------
-- "Organizer" everywhere below = first real (non-seed, non-deleted) account.

INSERT INTO club (owner_id, name, address, city)
SELECT u.id, 'Club Central', 'Av. Corrientes 1000', 'CABA'
FROM auth_user u
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND NOT EXISTS (SELECT 1 FROM club WHERE name = 'Club Central')
ORDER BY u.id LIMIT 1;

-- ---------------------------------------------------------------------------
-- Tournaments (level + lat/lon so the carousel can rank by level & distance).
-- Relative dates: always seeded a few days into the future.
-- ---------------------------------------------------------------------------

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT u.id, s.id, (SELECT id FROM club WHERE name = 'Club Central'),
       'Abierto de Pádel CABA', 'Torneo abierto, categorías por nivel.',
       date_trunc('hour', now()::timestamp) + interval '4 days',
       date_trunc('hour', now()::timestamp) + interval '5 days 11 hours',
       32, 'upcoming', 'intermediate', -34.603, -58.381
FROM auth_user u, sports s
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND s.name = 'Pádel'
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Abierto de Pádel CABA')
ORDER BY u.id LIMIT 1;

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT u.id, s.id, NULL,
       'Copa Pádel Norte', 'Nivel avanzado, cuadro eliminatorio.',
       date_trunc('hour', now()::timestamp) + interval '12 days',
       date_trunc('hour', now()::timestamp) + interval '13 days 9 hours',
       16, 'upcoming', 'advanced', -34.531, -58.472
FROM auth_user u, sports s
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND s.name = 'Pádel'
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Copa Pádel Norte')
ORDER BY u.id LIMIT 1;

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT u.id, s.id, NULL,
       'Torneo Tenis Primavera', 'Singles, ideal para arrancar a competir.',
       date_trunc('hour', now()::timestamp) + interval '7 days',
       date_trunc('hour', now()::timestamp) + interval '8 days 9 hours',
       24, 'upcoming', 'beginner', -34.611, -58.401
FROM auth_user u, sports s
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND s.name = 'Tenis'
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Torneo Tenis Primavera')
ORDER BY u.id LIMIT 1;

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT u.id, s.id, NULL,
       'Liga Fútbol 5', 'Fase de grupos + playoffs, equipos armados.',
       date_trunc('hour', now()::timestamp) + interval '9 days',
       date_trunc('hour', now()::timestamp) + interval '9 days 4 hours',
       20, 'upcoming', 'intermediate', -34.585, -58.443
FROM auth_user u, sports s
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND s.name = 'Fútbol 5'
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Liga Fútbol 5')
ORDER BY u.id LIMIT 1;

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT u.id, s.id, NULL,
       'Copa Vóley', 'Mixto 4x4, categoría intermedia.',
       date_trunc('hour', now()::timestamp) + interval '15 days',
       date_trunc('hour', now()::timestamp) + interval '15 days 5 hours',
       12, 'upcoming', 'intermediate', -34.623, -58.363
FROM auth_user u, sports s
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND s.name = 'Vóley'
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Copa Vóley')
ORDER BY u.id LIMIT 1;

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT u.id, s.id, NULL,
       'Slam Básquet 3x3', 'Formato 3x3, nivel avanzado.',
       date_trunc('hour', now()::timestamp) + interval '20 days',
       date_trunc('hour', now()::timestamp) + interval '20 days 10 hours',
       24, 'upcoming', 'advanced', -34.593, -58.391
FROM auth_user u, sports s
WHERE u.email NOT LIKE '%@seed.local' AND u.deleted_at IS NULL
  AND s.name = 'Básquet'
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Slam Básquet 3x3')
ORDER BY u.id LIMIT 1;

-- ---------------------------------------------------------------------------
-- Refresh: re-runs push expired SEED tournaments back into the future so the
-- carousels never quedan vacíos en dev. Solo toca los torneos de este seed
-- que siguen 'upcoming' pero cuya fecha ya pasó.
-- ---------------------------------------------------------------------------

UPDATE tournament
SET start_date = date_trunc('hour', now()::timestamp) + interval '7 days',
    end_date   = date_trunc('hour', now()::timestamp) + interval '8 days'
WHERE status = 'upcoming'
  AND start_date < now()::timestamp
  AND name IN ('Abierto de Pádel CABA', 'Copa Pádel Norte',
               'Torneo Tenis Primavera', 'Liga Fútbol 5', 'Copa Vóley',
               'Slam Básquet 3x3');
