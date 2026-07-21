from apps.common.exceptions.exceptions import AppException


class GameForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Solo el organizador puede hacer esto",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class GameStateException(AppException):
    """Raised when a state transition is invalid (e.g. joining a full game,
    reporting a result twice, leaving a finished game)."""
    def __init__(
        self,
        message: str = "El estado del partido no permite esta acción",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
