from datetime import datetime, timedelta

from apps.courts.models.models import CourtModel
from apps.courts.models.ddo import CourtDDO
from apps.courts.models.slots import (
    CourtSlotDDO,
    CourtSlotModel,
    SlotStateException,
)
from apps.courts.service.dto import (
    CourtOutputDTO,
    CourtSlotOutputDTO,
    CreatePrivateCourtInputDTO,
    UpdatePrivateCourtInputDTO,
)
from apps.courts.exceptions.exceptions import (
    CourtNotFoundException,
    CourtForbiddenException,
)

_SLOT_MIN = timedelta(minutes=30)
_SLOT_MAX = timedelta(hours=4)


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
            raise CourtNotFoundException(message=f"No encontramos la cancha {court_id}")
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
            raise CourtNotFoundException(message=f"No encontramos la cancha {court_id}")
        if existing.owner_id != current_user_id:
            raise CourtForbiddenException()

        deleted_id = await CourtModel().delete_court(court_id=court_id)
        if deleted_id is None:
            raise CourtNotFoundException(message=f"No encontramos la cancha {court_id}")
        return deleted_id

    # -------- turnos (court_slot) --------

    def _slot_to_dto(
        self, slot: CourtSlotDDO, show_booker: bool
    ) -> CourtSlotOutputDTO:
        data = slot.model_dump()
        if not show_booker:
            data["booked_by_name"] = None
        return CourtSlotOutputDTO(**data)

    async def _is_court_manager(
        self, court: CourtDDO, current_user_id: int
    ) -> bool:
        """Dueño del club (cancha de club) o dueño directo (cancha privada)."""
        if court.club_id is not None:
            from apps.clubs.models.models import ClubModel
            club = await ClubModel().get_club_by_id(club_id=court.club_id)
            return club.owner_id == current_user_id
        return court.owner_id == current_user_id

    async def _managed_court_for_slot(
        self, slot_id: int, current_user_id: int
    ) -> CourtSlotDDO:
        slot = await CourtSlotModel().get_slot(slot_id=slot_id)
        court = await CourtModel().get_court_by_id(
            court_id=slot.court_id, current_user_id=current_user_id
        )
        if not await self._is_court_manager(court, current_user_id):
            raise CourtForbiddenException(
                message="Solo quien administra la cancha puede gestionar sus turnos"
            )
        return slot

    async def slots_lister(
        self, court_id: int, current_user_id: int
    ) -> list[CourtSlotOutputDTO]:
        court = await CourtModel().get_court_by_id(
            court_id=court_id, current_user_id=current_user_id
        )
        manager = await self._is_court_manager(court, current_user_id)
        slots = await CourtSlotModel().list_slots(court_id=court_id)
        return [self._slot_to_dto(s, show_booker=manager) for s in slots]

    async def slot_creator(
        self,
        court_id: int,
        current_user_id: int,
        start_time: datetime,
        end_time: datetime,
    ) -> CourtSlotOutputDTO:
        court = await CourtModel().get_court_by_id(
            court_id=court_id, current_user_id=current_user_id
        )
        if not await self._is_court_manager(court, current_user_id):
            raise CourtForbiddenException(
                message="Solo quien administra la cancha puede crear turnos"
            )
        if end_time <= start_time:
            raise SlotStateException(
                message="El turno tiene que terminar después de empezar",
                error_code=400,
            )
        duration = end_time - start_time
        if duration < _SLOT_MIN or duration > _SLOT_MAX:
            raise SlotStateException(
                message="El turno tiene que durar entre 30 minutos y 4 horas",
                error_code=400,
            )
        if start_time <= datetime.now():
            raise SlotStateException(
                message="El turno tiene que ser en el futuro", error_code=400
            )
        slot = await CourtSlotModel().create_slot(
            court_id=court_id, start_time=start_time, end_time=end_time
        )
        return self._slot_to_dto(slot, show_booker=True)

    async def slot_deleter(self, slot_id: int, current_user_id: int) -> None:
        await self._managed_court_for_slot(slot_id, current_user_id)
        await CourtSlotModel().delete_slot(slot_id=slot_id)

    async def slot_status_setter(
        self, slot_id: int, current_user_id: int, status: str
    ) -> None:
        await self._managed_court_for_slot(slot_id, current_user_id)
        await CourtSlotModel().set_status(slot_id=slot_id, status=status)

    async def slot_booker(
        self, slot_id: int, current_user_id: int
    ) -> None:
        from apps.players.exceptions.exceptions import PlayerNotFoundException
        from apps.players.models.models import PlayerModel
        player = await PlayerModel().get_player_by_user_id(
            user_id=current_user_id
        )
        if player is None:
            raise PlayerNotFoundException(
                message=f"El usuario {current_user_id} no tiene perfil de jugador"
            )
        await CourtSlotModel().book_atomic(
            slot_id=slot_id, player_id=player.id
        )

    async def slot_booking_canceller(
        self, slot_id: int, current_user_id: int
    ) -> None:
        from apps.players.models.models import PlayerModel
        player = await PlayerModel().get_player_by_user_id(
            user_id=current_user_id
        )
        if player is None:
            from apps.players.exceptions.exceptions import (
                PlayerNotFoundException,
            )
            raise PlayerNotFoundException(
                message=f"El usuario {current_user_id} no tiene perfil de jugador"
            )
        await CourtSlotModel().cancel_booking_atomic(
            slot_id=slot_id, player_id=player.id
        )

    async def my_bookings_lister(
        self, current_user_id: int
    ) -> list[CourtSlotOutputDTO]:
        from apps.players.models.models import PlayerModel
        player = await PlayerModel().get_player_by_user_id(
            user_id=current_user_id
        )
        if player is None:
            return []
        slots = await CourtSlotModel().list_bookings_by_player(
            player_id=player.id
        )
        return [self._slot_to_dto(s, show_booker=False) for s in slots]
