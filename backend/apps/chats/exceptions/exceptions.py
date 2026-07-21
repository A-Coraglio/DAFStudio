from apps.common.exceptions.exceptions import AppException, NotFoundException


class ChatNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese chat") -> None:
        super().__init__(message=message)


class ChatForbiddenException(AppException):
    def __init__(
        self,
        message: str = "No podés ver este chat",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class MessageNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese mensaje") -> None:
        super().__init__(message=message)


class MessageForbiddenException(AppException):
    def __init__(
        self,
        message: str = "Solo podés editar o borrar tus propios mensajes",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
