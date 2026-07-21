from apps.common.exceptions.exceptions import AppException, NotFoundException


class LessonNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos esa clase") -> None:
        super().__init__(message=message)


class LessonStateException(AppException):
    """Booking conflicts: overlapping slot, cancelling twice, cancelling a
    lesson that already happened."""

    def __init__(
        self,
        message: str = "No es posible hacer eso con esta clase",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class LessonValidationException(AppException):
    """Invalid booking input: past date, inverted or absurd duration,
    booking yourself."""

    def __init__(
        self,
        message: str = "Los datos de la clase no son válidos",
        error_code: int = 400,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
