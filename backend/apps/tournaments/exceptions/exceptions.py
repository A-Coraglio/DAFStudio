from apps.common.exceptions.exceptions import AppException, NotFoundException


class TournamentNotFoundException(NotFoundException):
    def __init__(self, message: str = "No encontramos ese torneo") -> None:
        super().__init__(message=message)


class TournamentStateException(AppException):
    """Enrollment conflicts: closed registration, full roster, double join,
    leaving a tournament the player never joined."""

    def __init__(
        self,
        message: str = "No es posible hacer eso con este torneo",
        error_code: int = 409,
    ) -> None:
        super().__init__(message=message, error_code=error_code)
