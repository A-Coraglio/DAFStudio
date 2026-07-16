-- Seed data for the Tournaments and Classes features.
--
-- Fills the home carousels (recommended tournaments / classes) and their
-- search screens with realistic data around Buenos Aires (~ -34.6, -58.4).
-- Idempotent: every row is guarded with NOT EXISTS, so it is safe to re-run.
--
-- Tournaments are organised by the first real user (agus@agus.com); teachers
-- get their own seed auth_user + player (for a nice display name) + teacher +
-- teacher_sport row. Seed teacher accounts use a placeholder password hash and
-- are not meant to log in.

-- ---------------------------------------------------------------------------
-- Teacher accounts (auth_user + player + teacher + teacher_sport)
-- ---------------------------------------------------------------------------

-- Ana — Pádel
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_ana', 'ana@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.601, -58.383
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'ana@seed.local');

INSERT INTO player (user_id, ranking_points, first_name, last_name, level)
SELECT u.id, 0, 'Ana', 'Gómez', 'advanced'
FROM auth_user u WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Clases de pádel para todos los niveles. Técnica y táctica.', 8000, 6
FROM auth_user u WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Pádel')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Bruno — Tenis
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_bruno', 'bruno@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.582, -58.421
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'bruno@seed.local');

INSERT INTO player (user_id, ranking_points, first_name, last_name, level)
SELECT u.id, 0, 'Bruno', 'Fernández', 'intermediate'
FROM auth_user u WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Profe de tenis. Preparación física y saque.', 10000, 9
FROM auth_user u WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Tenis')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Carla — Pádel (más económica, más cerca)
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_carla', 'carla@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.615, -58.373
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'carla@seed.local');

INSERT INTO player (user_id, ranking_points, first_name, last_name, level)
SELECT u.id, 0, 'Carla', 'Ruiz', 'beginner'
FROM auth_user u WHERE u.email = 'carla@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Iniciación al pádel. Clases grupales y particulares.', 7000, 3
FROM auth_user u WHERE u.email = 'carla@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Pádel')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'carla@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Diego — Fútbol
INSERT INTO auth_user (username, email, password_hash, home_lat, home_lon)
SELECT 'profe_diego', 'diego@seed.local', '$2b$12$seedplaceholderseedplaceholderseedpla', -34.551, -58.462
WHERE NOT EXISTS (SELECT 1 FROM auth_user WHERE email = 'diego@seed.local');

INSERT INTO player (user_id, ranking_points, first_name, last_name, level)
SELECT u.id, 0, 'Diego', 'López', 'intermediate'
FROM auth_user u WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM player p WHERE p.user_id = u.id);

INSERT INTO teacher (user_id, bio, price_per_hour, experience_years)
SELECT u.id, 'Entrenador de fútbol. Fundamentos y juego de posición.', 6000, 12
FROM auth_user u WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher t WHERE t.user_id = u.id);

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Fútbol 5')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id);

-- Extra sports per teacher (requires the composite teacher_sport PK). Some
-- teachers coach more than one sport.
--   Ana   -> Pádel + Tenis
--   Bruno -> Tenis + Pádel
--   Diego -> Fútbol 5 + Fútbol 7
INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Tenis')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'ana@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id
                  AND ts.sport_id = (SELECT id FROM sports WHERE name = 'Tenis'));

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Pádel')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'bruno@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id
                  AND ts.sport_id = (SELECT id FROM sports WHERE name = 'Pádel'));

INSERT INTO teacher_sport (teacher_id, sport_id)
SELECT t.id, (SELECT id FROM sports WHERE name = 'Fútbol 7')
FROM teacher t JOIN auth_user u ON u.id = t.user_id
WHERE u.email = 'diego@seed.local'
  AND NOT EXISTS (SELECT 1 FROM teacher_sport ts WHERE ts.teacher_id = t.id
                  AND ts.sport_id = (SELECT id FROM sports WHERE name = 'Fútbol 7'));

-- ---------------------------------------------------------------------------
-- Clubs (optional host for tournaments)
-- ---------------------------------------------------------------------------

INSERT INTO club (owner_id, name, address, city)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       'Club Central', 'Av. Corrientes 1000', 'CABA'
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM club WHERE name = 'Club Central');

-- ---------------------------------------------------------------------------
-- Tournaments (level + lat/lon so the carousel can rank by level & distance)
-- ---------------------------------------------------------------------------

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       (SELECT id FROM sports WHERE name = 'Pádel'),
       (SELECT id FROM club WHERE name = 'Club Central'),
       'Abierto de Pádel CABA', 'Torneo abierto, categorías por nivel.',
       TIMESTAMP '2026-07-25 09:00', TIMESTAMP '2026-07-26 20:00',
       32, 'upcoming', 'intermediate', -34.603, -58.381
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Abierto de Pádel CABA');

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       (SELECT id FROM sports WHERE name = 'Pádel'), NULL,
       'Copa Pádel Norte', 'Nivel avanzado, cuadro eliminatorio.',
       TIMESTAMP '2026-08-02 10:00', TIMESTAMP '2026-08-03 19:00',
       16, 'upcoming', 'advanced', -34.531, -58.472
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Copa Pádel Norte');

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       (SELECT id FROM sports WHERE name = 'Tenis'), NULL,
       'Torneo Tenis Primavera', 'Singles, ideal para arrancar a competir.',
       TIMESTAMP '2026-07-28 09:00', TIMESTAMP '2026-07-29 18:00',
       24, 'upcoming', 'beginner', -34.611, -58.401
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Torneo Tenis Primavera');

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       (SELECT id FROM sports WHERE name = 'Fútbol 5'), NULL,
       'Liga Fútbol 5', 'Fase de grupos + playoffs, equipos armados.',
       TIMESTAMP '2026-07-30 19:00', TIMESTAMP '2026-07-30 23:00',
       20, 'upcoming', 'intermediate', -34.585, -58.443
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Liga Fútbol 5');

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       (SELECT id FROM sports WHERE name = 'Vóley'), NULL,
       'Copa Vóley', 'Mixto 4x4, categoría intermedia.',
       TIMESTAMP '2026-08-05 18:00', TIMESTAMP '2026-08-05 23:00',
       12, 'upcoming', 'intermediate', -34.623, -58.363
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Copa Vóley');

INSERT INTO tournament (organizer_id, sport_id, club_id, name, description,
                        start_date, end_date, max_participants, status, level, lat, lon)
SELECT (SELECT id FROM auth_user WHERE email = 'agus@agus.com'),
       (SELECT id FROM sports WHERE name = 'Básquet'), NULL,
       'Slam Básquet 3x3', 'Formato 3x3, nivel avanzado.',
       TIMESTAMP '2026-08-10 10:00', TIMESTAMP '2026-08-10 20:00',
       24, 'upcoming', 'advanced', -34.593, -58.391
WHERE EXISTS (SELECT 1 FROM auth_user WHERE email = 'agus@agus.com')
  AND NOT EXISTS (SELECT 1 FROM tournament WHERE name = 'Slam Básquet 3x3');
