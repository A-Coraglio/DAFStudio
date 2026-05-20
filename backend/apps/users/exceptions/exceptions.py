from apps.common.exceptions.exceptions import AppException, NotFoundException


class UnauthorizedException(AppException):
    def __init__(self, message: str = "Unauthorized", error_code: int = 401) -> None:
        super().__init__(message=message, error_code=error_code)


class ForbiddenException(AppException):
    def __init__(self, message: str = "Forbidden", error_code: int = 403) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidCredentialsException(UnauthorizedException):
    def __init__(self, message: str = "Usuario o contraseña incorrectos") -> None:
        super().__init__(message=message)


class UserNotFoundException(NotFoundException):
    def __init__(self, message: str = "User not found") -> None:
        super().__init__(message=message)


class EmailAlreadyRegisteredException(AppException):
    def __init__(
        self,
        message: str = "El email ya está registrado",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class GoogleAuthNotConfiguredException(AppException):
    """Server is not configured to accept Google sign-ins (no client id set).
    Surfaces as 503 so the client can show a sensible message and fall back
    to email/password."""
    def __init__(
        self,
        message: str = "Login con Google no configurado en el servidor",
        error_code: int = 503,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidGoogleTokenException(UnauthorizedException):
    def __init__(self, message: str = "Token de Google inválido") -> None:
        super().__init__(message=message)
