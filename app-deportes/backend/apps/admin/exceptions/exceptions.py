from apps.common.exceptions.exceptions import AppException


class AdminForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Necesitás permisos de administrador",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class AdminActionException(AppException):
    """Acciones inválidas: banearse/eliminarse a uno mismo, degradar al
    último admin, banear a otro admin, etc."""

    def __init__(
        self,
        message: str = "Esa acción de administración no es válida",
        error_code: int = 400,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
