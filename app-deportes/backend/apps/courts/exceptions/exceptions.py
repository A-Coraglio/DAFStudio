from apps.common.exceptions.exceptions import AppException, NotFoundException


class CourtNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos esa cancha") -> None:
        super().__init__(message=message)


class CourtForbiddenException(AppException):
    def __init__(
        self,
        message: str = "No podés modificar una cancha que no es tuya",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
