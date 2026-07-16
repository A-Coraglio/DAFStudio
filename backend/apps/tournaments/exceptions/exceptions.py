from apps.common.exceptions.exceptions import NotFoundException


class TournamentNotFoundException(NotFoundException):
    def __init__(self, message: str = "Tournament not found") -> None:
        super().__init__(message=message)
