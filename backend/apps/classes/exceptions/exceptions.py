from apps.common.exceptions.exceptions import NotFoundException


class ClassNotFoundException(NotFoundException):
    def __init__(self, message: str = "Class (teacher) not found") -> None:
        super().__init__(message=message)
