from apps.common.exceptions.exceptions import AppException, NotFoundException


class PlayerNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese jugador") -> None:
        super().__init__(message=message)


class PlayerAlreadyExistsException(AppException):
    def __init__(
        self,
        message: str = "Este usuario ya tiene perfil de jugador",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
