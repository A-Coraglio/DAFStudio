from apps.games.exceptions.exceptions import NotFoundException


class SportModeNotFoundException(NotFoundException):
    def __init__(self, message: str = "Sport mode not found") -> None:
        super().__init__(message=message)
