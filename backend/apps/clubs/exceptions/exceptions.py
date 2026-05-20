from apps.common.exceptions.exceptions import AppException, NotFoundException


class ClubNotFoundException(NotFoundException):
    def __init__(self, message: str = "Club not found") -> None:
        super().__init__(message=message)


class ClubForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Only the club owner can perform this action",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
