from apps.clubs.models.models import ClubModel
from apps.clubs.models.ddo import ClubDDO
from apps.clubs.service.dto import (
    ClubOutputDTO,
    CreateClubInputDTO,
    UpdateClubInputDTO,
)
from apps.clubs.exceptions.exceptions import (
    ClubNotFoundException,
    ClubForbiddenException,
)
from apps.courts.service.appservice import AppService as CourtsAppService
from apps.courts.service.dto import (
    CourtOutputDTO,
    CreatePrivateCourtInputDTO,
)


class AppService:

    def _to_output_dto(self, club: ClubDDO) -> ClubOutputDTO:
        return ClubOutputDTO(
            id=club.id,
            owner_id=club.owner_id,
            name=club.name,
            address=club.address,
            city=club.city,
            description=club.description,
        )

    async def clubs_lister(self, city: str | None = None) -> list[ClubOutputDTO]:
        clubs = await ClubModel().list_clubs(city=city)
        return [self._to_output_dto(c) for c in clubs]

    async def my_clubs_lister(self, owner_id: int) -> list[ClubOutputDTO]:
        clubs = await ClubModel().list_by_owner(owner_id=owner_id)
        return [self._to_output_dto(c) for c in clubs]

    async def clubs_creator_admin(
        self, data: CreateClubInputDTO, admin_user_id: int
    ) -> ClubOutputDTO:
        """Alta de club (solo admin, decisión 2026-07-21): valida que el
        dueño exista y deja la acción auditada."""
        from apps.admin.models.models import AuditModel
        from apps.users.service.authservice import AuthService
        await AuthService().users_getter(user_id=data.owner_user_id)
        club = await self.clubs_creator(data=data, owner_id=data.owner_user_id)
        await AuditModel().record(
            admin_user_id=admin_user_id,
            action="create_club",
            target_type="user",
            target_id=data.owner_user_id,
            detail=f"club {club.id}: {club.name}",
        )
        return club

    async def clubs_getter(self, club_id: int) -> ClubOutputDTO:
        club = await ClubModel().get_club_by_id(club_id=club_id)
        return self._to_output_dto(club)

    async def clubs_creator(
        self, data: CreateClubInputDTO, owner_id: int
    ) -> ClubOutputDTO:
        club = await ClubModel().create_club(
            owner_id=owner_id,
            name=data.name,
            address=data.address,
            city=data.city,
            description=data.description,
        )
        return self._to_output_dto(club)

    async def clubs_updater(
        self,
        club_id: int,
        data: UpdateClubInputDTO,
        current_user_id: int,
    ) -> ClubOutputDTO:
        existing = await ClubModel().get_club_by_id(club_id=club_id)
        if existing.owner_id != current_user_id:
            raise ClubForbiddenException()

        updated = await ClubModel().update_club(
            club_id=club_id,
            name=data.name,
            address=data.address,
            city=data.city,
            description=data.description,
        )
        return self._to_output_dto(updated or existing)

    async def clubs_deleter(self, club_id: int, current_user_id: int) -> int:
        existing = await ClubModel().get_club_by_id(club_id=club_id)
        if existing.owner_id != current_user_id:
            raise ClubForbiddenException()

        deleted_id = await ClubModel().delete_club(club_id=club_id)
        if deleted_id is None:
            raise ClubNotFoundException(message=f"No encontramos el club {club_id}")
        return deleted_id

    # ---- nested courts ----

    async def clubs_list_courts(
        self, club_id: int, current_user_id: int
    ) -> list[CourtOutputDTO]:
        # Confirm the club exists so we return 404 instead of an empty list
        # when the club_id is bogus.
        await ClubModel().get_club_by_id(club_id=club_id)
        return await CourtsAppService().courts_lister(
            current_user_id=current_user_id,
            club_id=club_id,
        )

    async def clubs_create_court(
        self,
        club_id: int,
        data: CreatePrivateCourtInputDTO,
        current_user_id: int,
    ) -> CourtOutputDTO:
        club = await ClubModel().get_club_by_id(club_id=club_id)
        if club.owner_id != current_user_id:
            raise ClubForbiddenException(
                message="Solo el dueño del club puede agregarle canchas"
            )
        return await CourtsAppService().courts_creator_club(
            data=data, club_id=club_id
        )
