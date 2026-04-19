class AppException(Exception):
    def __init__(self, message, error_code) -> None:
        super().__init__(message)
        self.error_code = error_code


class NotFoundException(AppException):
    def __init__(self, message, error_code = 404) -> None:
        super().__init__(message=message, error_code=error_code)
        self.error_code = error_code

class DatbaseException(AppException):
    def __init__(self, message, error_code = 400) -> None:
        super().__init__(message=message, error_code=error_code)
        self.error_code = error_code


class GameForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Only the organizer can perform this action",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class GameStateException(AppException):
    """Raised when a state transition is invalid (e.g. joining a full game,
    reporting a result twice, leaving a finished game)."""
    def __init__(self, message: str = "Invalid game state", error_code: int = 409) -> None:
        super().__init__(message=message, error_code=error_code)



