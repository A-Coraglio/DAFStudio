from apps.common.exceptions.exceptions import NotFoundException


class SportModeNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese modo de juego") -> None:
        super().__init__(message=message)
