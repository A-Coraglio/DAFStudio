from datetime import datetime, timezone


def iso_utc(dt: datetime) -> str:
    """Serialize a datetime as ISO-8601 with an explicit UTC offset.

    asyncpg returns naive datetimes when the column is `TIMESTAMP` (as opposed
    to `TIMESTAMPTZ`). Our event-time columns (`created_at`, `proposed_at`,
    etc.) are always stored in UTC — we just lack a tz marker. This helper
    stamps `+00:00` so clients don't reinterpret the value as their local
    time. Do NOT use for user-facing "clock time" columns (e.g. `scheduled_at`,
    `window_start/end`) where the frontend picked a naive local timestamp and
    expects to render it back unchanged.
    """
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.isoformat()
