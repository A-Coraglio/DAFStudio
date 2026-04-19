from apps.games.exceptions.exceptions import AppException, NotFoundException


class PlayerNotFoundException(NotFoundException):
    def __init__(self, message: str = "Player not found") -> None:
        super().__init__(message=message)


class PlayerAlreadyExistsException(AppException):
    def __init__(
        self,
        message: str = "Player profile already exists for this user",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
