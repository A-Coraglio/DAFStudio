from apps.common.exceptions.exceptions import AppException, NotFoundException


class TicketNotFoundException(NotFoundException):
    def __init__(self, message: str = "No tenés una búsqueda activa") -> None:
        super().__init__(message=message)


class TicketForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Esa búsqueda no te pertenece",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class AlreadyInQueueException(AppException):
    def __init__(
        self,
        message: str = "Ya estás en una búsqueda de partido",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidTicketStateException(AppException):
    def __init__(
        self, message: str = "La búsqueda ya no está activa",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
