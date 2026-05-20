from apps.common.exceptions.exceptions import AppException, NotFoundException


class TicketNotFoundException(NotFoundException):
    def __init__(self, message: str = "Matchmaking ticket not found") -> None:
        super().__init__(message=message)


class TicketForbiddenException(AppException):
    def __init__(
        self,
        message: str = "This ticket does not belong to you",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class AlreadyInQueueException(AppException):
    def __init__(
        self,
        message: str = "You already have an active matchmaking ticket",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidTicketStateException(AppException):
    def __init__(
        self, message: str = "Ticket state does not allow this action",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
