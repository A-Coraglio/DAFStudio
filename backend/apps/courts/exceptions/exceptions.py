from apps.games.exceptions.exceptions import AppException, NotFoundException


class CourtNotFoundException(NotFoundException):
    def __init__(self, message: str = "Court not found") -> None:
        super().__init__(message=message)


class CourtForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Cannot modify a court you do not own",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
