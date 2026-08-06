from datetime import datetime
from typing import cast

from asyncpg.pool import PoolConnectionProxy
from pydantic import BaseModel, Field

from apps.tournaments.models import GeneralModel
from apps.tournaments.exceptions.exceptions import (
    TournamentNotFoundException,
    TournamentStateException,
)
from apps.common.exceptions.exceptions import AppException, DatabaseException


class TournamentParticipantDDO(BaseModel):
    player_id: int
    user_id: int
    display_name: str = Field(description="Player name (or username fallback)")
    level: str | None = Field(default=None)
    avatar_path: str | None = Field(default=None)
    created_at: datetime


def _row_to_ddo(row) -> TournamentParticipantDDO:
    name = " ".join(
        p for p in (row["first_name"], row["last_name"]) if p
    ).strip()
    return TournamentParticipantDDO(
        player_id=row["player_id"],
        user_id=row["user_id"],
        display_name=name if name else row["username"],
        level=row["level"],
        avatar_path=row["avatar_path"],
        created_at=row["created_at"],
    )


class TournamentParticipantModel(GeneralModel):
    __table_name__ = "tournament_participant"

    _LIST_SELECT = (
        "SELECT tp.player_id, tp.created_at, p.user_id, p.first_name, "
        "p.last_name, p.level, p.avatar_path, u.username "
        "FROM tournament_participant tp "
        "JOIN player p ON p.id = tp.player_id "
        "JOIN auth_user u ON u.id = p.user_id "
    )

    async def list_participants(
        self, tournament_id: int
    ) -> list[TournamentParticipantDDO]:
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            query = (
                f"{self._LIST_SELECT}"
                "WHERE tp.tournament_id = $1 ORDER BY tp.created_at"
            )
            try:
                results = await connection.fetch(query, tournament_id)
                return [_row_to_ddo(r) for r in results]
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def join_atomic(self, tournament_id: int, player_id: int) -> None:
        """Single-transaction enrollment. Locks the tournament row (FOR
        UPDATE) so two concurrent joins can't overbook max_participants —
        validations and the insert see a frozen state."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    tournament = await connection.fetchrow(
                        "SELECT status, max_participants FROM tournament "
                        "WHERE id = $1 FOR UPDATE",
                        tournament_id,
                    )
                    if tournament is None:
                        raise TournamentNotFoundException(
                            message=f"No encontramos el torneo {tournament_id}"
                        )
                    if tournament["status"] != "upcoming":
                        raise TournamentStateException(
                            message="Las inscripciones de este torneo ya cerraron"
                        )
                    already = await connection.fetchrow(
                        f"SELECT 1 FROM {self.__table_name__} "
                        "WHERE tournament_id = $1 AND player_id = $2",
                        tournament_id, player_id,
                    )
                    if already:
                        raise TournamentStateException(
                            message="Ya estás inscripto en este torneo"
                        )
                    count = await connection.fetchval(
                        f"SELECT COUNT(*) FROM {self.__table_name__} "
                        "WHERE tournament_id = $1",
                        tournament_id,
                    )
                    if count >= tournament["max_participants"]:
                        raise TournamentStateException(
                            message="El torneo está completo"
                        )
                    await connection.execute(
                        f"INSERT INTO {self.__table_name__} "
                        "(tournament_id, player_id) VALUES ($1, $2)",
                        tournament_id, player_id,
                    )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")

    async def leave_atomic(self, tournament_id: int, player_id: int) -> None:
        """Unenroll. Only while the tournament is still 'upcoming' — once it
        started the roster is frozen."""
        async with self.get_db_connection() as connection:
            connection: PoolConnectionProxy = cast(PoolConnectionProxy, connection)
            try:
                async with connection.transaction():
                    tournament = await connection.fetchrow(
                        "SELECT status FROM tournament WHERE id = $1 FOR UPDATE",
                        tournament_id,
                    )
                    if tournament is None:
                        raise TournamentNotFoundException(
                            message=f"No encontramos el torneo {tournament_id}"
                        )
                    if tournament["status"] != "upcoming":
                        raise TournamentStateException(
                            message="El torneo ya empezó: no es posible darse de baja"
                        )
                    deleted = await connection.fetchrow(
                        f"DELETE FROM {self.__table_name__} "
                        "WHERE tournament_id = $1 AND player_id = $2 "
                        "RETURNING player_id",
                        tournament_id, player_id,
                    )
                    if deleted is None:
                        raise TournamentStateException(
                            message="No estás inscripto en este torneo"
                        )
            except AppException:
                raise
            except Exception as e:
                raise DatabaseException(message=f"Database error: {e}")
