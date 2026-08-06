from apps.common.exceptions.exceptions import NotFoundException


class SportNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese deporte") -> None:
        super().__init__(message=message)
