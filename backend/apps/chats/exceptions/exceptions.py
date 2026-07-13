from apps.common.exceptions.exceptions import AppException, NotFoundException


class ChatNotFoundException(NotFoundException):
    def __init__(self, message: str = "Chat not found") -> None:
        super().__init__(message=message)


class ChatForbiddenException(AppException):
    def __init__(
        self,
        message: str = "You are not a participant of this chat",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)


class MessageNotFoundException(NotFoundException):
    def __init__(self, message: str = "Message not found") -> None:
        super().__init__(message=message)


class MessageForbiddenException(AppException):
    def __init__(
        self,
        message: str = "You can only edit or delete your own messages",
        error_code: int = 403,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
