from apps.common.exceptions.exceptions import AppException, NotFoundException


class UnauthorizedException(AppException):
    def __init__(
        self,
        message: str = "Tu sesión expiró. Ingresá de nuevo",
        error_code: int = 401,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class ForbiddenException(AppException):
    def __init__(
        self,
        message: str = "No tenés permiso para hacer esto",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidCredentialsException(UnauthorizedException):
    def __init__(self, message: str = "Usuario o contraseña incorrectos") -> None:
        super().__init__(message=message)


class UserNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese usuario") -> None:
        super().__init__(message=message)


class InvalidHomeLocationException(AppException):
    def __init__(
        self,
        message: str = "La ubicación de casa no es válida",
        error_code: int = 400,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class EmailAlreadyRegisteredException(AppException):
    def __init__(
        self,
        message: str = "El email ya está registrado",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class UsernameAlreadyRegisteredException(AppException):
    def __init__(
        self,
        message: str = "El nombre de usuario ya está en uso",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidRegistrationException(AppException):
    """Bad registration input (weak password, malformed email, short
    username). 400 with a user-facing Spanish message — kept as AppException
    instead of pydantic validators so the client renders it like any other
    business error."""
    def __init__(self, message: str, error_code: int = 400) -> None:
        super().__init__(message=message, error_code=error_code)


class InvalidPasswordChangeException(AppException):
    """Current password missing or wrong when trying to set a new one. 400 on
    purpose — a 401 would make the client interceptor log the user out."""
    def __init__(
        self,
        message: str = "La contraseña actual es incorrecta",
        error_code: int = 400,
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
