from apps.common.exceptions.exceptions import NotFoundException


class TournamentNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese torneo") -> None:
        super().__init__(message=message)
