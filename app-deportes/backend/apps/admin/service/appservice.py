from apps.admin.exceptions.exceptions import AdminActionException
from apps.admin.models.ddo import AdminUserDDO, AuditEntryDDO
from apps.admin.models.models import AdminModel, AuditModel
from apps.admin.service.dto import (
    AdminUserOutputDTO,
    AuditEntryOutputDTO,
    LogsOutputDTO,
)
from apps.common.log_file import tail_log
from apps.games.models.models import GamesModel
from apps.games.models.game_player import GamePlayerModel
from apps.teachers.models.models import TeacherModel
from apps.teachers.service.dto import TeacherRequestOutputDTO
from apps.users.service.authservice import AuthService


class AppService:

    def _user_to_dto(self, user: AdminUserDDO) -> AdminUserOutputDTO:
        return AdminUserOutputDTO(**user.model_dump())

    def _audit_to_dto(self, entry: AuditEntryDDO) -> AuditEntryOutputDTO:
        return AuditEntryOutputDTO(**entry.model_dump())

    # -------- usuarios --------

    async def users_lister(
        self, query: str | None, limit: int, offset: int
    ) -> list[AdminUserOutputDTO]:
        rows = await AdminModel().list_users(
            query=query, limit=limit, offset=offset
        )
        return [self._user_to_dto(u) for u in rows]

    async def user_banner(
        self, admin_user_id: int, target_user_id: int, banned: bool
    ) -> None:
        if target_user_id == admin_user_id:
            raise AdminActionException(message="No podés banearte a vos mismo")
        if banned and await AdminModel().is_admin(user_id=target_user_id):
            raise AdminActionException(
                message="No se puede banear a otro admin: primero quitale el rol"
            )
        ok = await AdminModel().set_banned(
            user_id=target_user_id, banned=banned
        )
        if not ok:
            raise AdminActionException(
                message="No encontramos esa cuenta (o está eliminada)",
                error_code=404,
            )
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="ban" if banned else "unban",
            target_type="user",
            target_id=target_user_id,
        )

    async def user_deleter(
        self, admin_user_id: int, target_user_id: int
    ) -> None:
        if target_user_id == admin_user_id:
            raise AdminActionException(
                message="No podés eliminar tu propia cuenta desde el panel"
            )
        if await AdminModel().is_admin(user_id=target_user_id):
            raise AdminActionException(
                message="No se puede eliminar a otro admin: primero quitale el rol"
            )
        # Mismo soft-delete + anonimización del flujo de usuarios.
        await AuthService().users_deleter(user_id=target_user_id)
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="delete_user",
            target_type="user",
            target_id=target_user_id,
        )

    async def user_promoter(
        self, admin_user_id: int, target_user_id: int, promote: bool
    ) -> None:
        if promote:
            # 404 si la cuenta no existe / está borrada.
            await AuthService().users_getter(user_id=target_user_id)
            await AdminModel().add_admin(user_id=target_user_id)
        else:
            if (
                target_user_id == admin_user_id
                and await AdminModel().count_admins() <= 1
            ):
                raise AdminActionException(
                    message="Sos el último admin: no podés dejar la app sin administradores"
                )
            await AdminModel().remove_admin(user_id=target_user_id)
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="promote" if promote else "demote",
            target_type="user",
            target_id=target_user_id,
        )

    # -------- partidos --------

    async def game_canceller(self, admin_user_id: int, game_id: int) -> None:
        game = await GamesModel().get_game_by_id(game_id=game_id)
        if game.status in ("finished", "cancelled"):
            raise AdminActionException(
                message="Ese partido ya está terminado o cancelado"
            )
        await GamesModel().update_game(game_id=game_id, status="cancelled")
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="cancel_game",
            target_type="game",
            target_id=game_id,
            detail=game.name,
        )

    async def player_kicker(
        self, admin_user_id: int, game_id: int, player_id: int
    ) -> None:
        game = await GamesModel().get_game_by_id(game_id=game_id)
        if game.status not in ("open", "full"):
            raise AdminActionException(
                message="Ese partido ya no admite cambios de jugadores"
            )
        removed = await GamePlayerModel().remove_player(
            game_id=game_id, player_id=player_id
        )
        if not removed:
            raise AdminActionException(
                message="Ese jugador no está en el partido", error_code=404
            )
        if game.status == "full":
            # Igual que cuando alguien se va: vuelve a haber lugar.
            await GamesModel().update_game(game_id=game_id, status="open")
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="kick_player",
            target_type="game",
            target_id=game_id,
            detail=f"player {player_id}",
        )

    # -------- solicitudes de profesor --------

    async def teacher_requests_lister(self) -> list[TeacherRequestOutputDTO]:
        rows = await TeacherModel().list_pending_requests()
        return [TeacherRequestOutputDTO(**r.model_dump()) for r in rows]

    async def teacher_request_resolver(
        self, admin_user_id: int, request_id: int, approve: bool
    ) -> None:
        """Aprueba (crea el teacher + sus deportes) o rechaza, y audita."""
        applicant_user_id = await TeacherModel().resolve_request_atomic(
            request_id=request_id, approve=approve
        )
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="teacher_approve" if approve else "teacher_reject",
            target_type="user",
            target_id=applicant_user_id,
        )

    # -------- auditoría y logs --------

    async def audit_lister(
        self, limit: int, offset: int
    ) -> list[AuditEntryOutputDTO]:
        rows = await AuditModel().list_entries(limit=limit, offset=offset)
        return [self._audit_to_dto(e) for e in rows]

    def logs_reader(self, lines: int) -> LogsOutputDTO:
        return LogsOutputDTO(lines=tail_log(lines=lines))
