from apps.common.exceptions.exceptions import NotFoundException


class ClassNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos esa clase") -> None:
        super().__init__(message=message)
