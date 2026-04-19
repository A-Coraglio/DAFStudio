from apps.games.exceptions.exceptions import NotFoundException


class SportNotFoundException(NotFoundException):
    def __init__(self, message: str = "Sport not found") -> None:
        super().__init__(message=message)
