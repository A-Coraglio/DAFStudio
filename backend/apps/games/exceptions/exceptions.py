class AppException(Exception):
    def __init__(self, message, error_code) -> None:
        super().__init__(message)
        self.error_code = error_code


class NotFoundException(AppException):
    def __init__(self, message, error_code = 404) -> None:
        super().__init__(message=message, error_code=error_code)
        self.error_code = error_code

class DatbaseException(AppException):
    def __init__(self, message, error_code = 400) -> None:
        super().__init__(message=message, error_code=error_code)
        self.error_code = error_code



