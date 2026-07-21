from apps.common.exceptions.exceptions import AppException, NotFoundException


class ClubNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese club") -> None:
        super().__init__(message=message)


class ClubForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Solo el dueño del club puede hacer esto",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
