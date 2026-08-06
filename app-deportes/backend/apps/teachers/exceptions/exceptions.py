from apps.common.exceptions.exceptions import AppException, NotFoundException


class TeacherNotFoundException(NotFoundException):
    def __init__(self, message: str = "No sos profesor todavía") -> None:
        super().__init__(message=message)


class TeacherRequestException(AppException):
    """Solicitudes inválidas: ya sos profe, ya tenés una pendiente, datos
    incompletos."""

    def __init__(
        self,
        message: str = "La solicitud de profesor no es válida",
        error_code: int = 400,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
