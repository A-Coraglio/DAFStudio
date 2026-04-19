from apps.courts.models.models import CourtModel
from apps.courts.models.ddo import CourtDDO
from apps.courts.service.dto import (
    CourtOutputDTO,
    CreatePrivateCourtInputDTO,
    UpdatePrivateCourtInputDTO,
)
from apps.courts.exceptions.exceptions import (
    CourtNotFoundException,
    CourtForbiddenException,
)


class AppService:

    def _to_output_dto(self, court: CourtDDO) -> CourtOutputDTO:
        return CourtOutputDTO(
            id=court.id,
            club_id=court.club_id,
            owner_id=court.owner_id,
            sport_id=court.sport_id,
            name=court.name,
            price_per_hour=court.price_per_hour,
            is_indoor=court.is_indoor,
            lat=court.lat,
            lon=court.lon,
        )

    async def courts_lister(
        self,
        current_user_id: int,
        sport_id: int | None = None,
        club_id: int | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
    ) -> list[CourtOutputDTO]:
        courts: list[CourtDDO] = await CourtModel().list_courts(
            current_user_id=current_user_id,
            sport_id=sport_id,
            club_id=club_id,
            near_lat=near_lat,
            near_lon=near_lon,
            radius_km=radius_km,
        )
        return [self._to_output_dto(c) for c in courts]

    async def courts_getter(
        self, court_id: int, current_user_id: int
    ) -> CourtOutputDTO:
        court: CourtDDO = await CourtModel().get_court_by_id(
            court_id=court_id, current_user_id=current_user_id
        )
        return self._to_output_dto(court)

    async def courts_creator_private(
        self,
        data: CreatePrivateCourtInputDTO,
        owner_id: int,
    ) -> CourtOutputDTO:
        court: CourtDDO = await CourtModel().create_private_court(
            name=data.name,
            sport_id=data.sport_id,
            owner_id=owner_id,
            price_per_hour=data.price_per_hour,
            is_indoor=data.is_indoor,
            lat=data.lat,
            lon=data.lon,
        )
        return self._to_output_dto(court)

    async def courts_creator_club(
        self,
        data: CreatePrivateCourtInputDTO,
        club_id: int,
    ) -> CourtOutputDTO:
        """Called by the clubs service after it validates that the caller owns
        the club. Creates a court with club_id set (and owner_id null)."""
        court: CourtDDO = await CourtModel().create_club_court(
            name=data.name,
            sport_id=data.sport_id,
            club_id=club_id,
            price_per_hour=data.price_per_hour,
            is_indoor=data.is_indoor,
            lat=data.lat,
            lon=data.lon,
        )
        return self._to_output_dto(court)

    async def courts_updater_private(
        self,
        court_id: int,
        data: UpdatePrivateCourtInputDTO,
        current_user_id: int,
    ) -> CourtOutputDTO:
        existing = await CourtModel().get_court_raw(court_id=court_id)
        if existing is None:
            raise CourtNotFoundException(message=f"Court with id {court_id} not found")
        if existing.owner_id != current_user_id:
            # Either a club court or someone else's private court.
            raise CourtForbiddenException()

        updated = await CourtModel().update_private_court(
            court_id=court_id,
            name=data.name,
            sport_id=data.sport_id,
            price_per_hour=data.price_per_hour,
            is_indoor=data.is_indoor,
            lat=data.lat,
            lon=data.lon,
        )
        return self._to_output_dto(updated or existing)

    async def courts_deleter_private(
        self, court_id: int, current_user_id: int
    ) -> int:
        existing = await CourtModel().get_court_raw(court_id=court_id)
        if existing is None:
            raise CourtNotFoundException(message=f"Court with id {court_id} not found")
        if existing.owner_id != current_user_id:
            raise CourtForbiddenException()

        deleted_id = await CourtModel().delete_court(court_id=court_id)
        if deleted_id is None:
            raise CourtNotFoundException(message=f"Court with id {court_id} not found")
        return deleted_id
