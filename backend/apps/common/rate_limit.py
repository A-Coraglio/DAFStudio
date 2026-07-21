import time
from collections import defaultdict, deque

from fastapi import Request

from apps.common.exceptions.exceptions import AppException


class RateLimitException(AppException):
    def __init__(
        self,
        message: str = "Demasiados intentos. Esperá un momento y probá de nuevo",
        error_code: int = 429,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


def rate_limit(max_calls: int, per_seconds: float):
    """Returns a FastAPI dependency that allows `max_calls` per client IP in a
    sliding window of `per_seconds`. In-memory and per-process on purpose: it
    exists to blunt brute-force on login/register and matcher-triggering spam,
    not to be exact accounting (a restart clears it, and that's fine)."""
    buckets: dict[str, deque] = defaultdict(deque)

    async def dependency(request: Request) -> None:
        key = request.client.host if request.client else "unknown"
        now = time.monotonic()
        window = buckets[key]
        while window and now - window[0] > per_seconds:
            window.popleft()
        if len(window) >= max_calls:
            raise RateLimitException()
        window.append(now)

    return dependency
