from apps.classes.models.models import ClassModel
from apps.classes.models.ddo import ClassDDO
from apps.classes.service.dto import ClassOutputDTO
from apps.players.models.models import PlayerModel


class AppService:

    def _to_output_dto(self, item: ClassDDO) -> ClassOutputDTO:
        return ClassOutputDTO(**item.model_dump())

    async def classes_lister(
        self,
        sport_id: int | None = None,
        max_price: float | None = None,
        near_lat: float | None = None,
        near_lon: float | None = None,
        radius_km: float | None = None,
        limit: int = 30,
        offset: int = 0,
    ) -> list[ClassOutputDTO]:
        rows = await ClassModel().list_classes(
            sport_id=sport_id,
            max_price=max_price,
            near_lat=near_lat,
            near_lon=near_lon,
            radius_km=radius_km,
            limit=limit,
            offset=offset,
        )
        return [self._to_output_dto(c) for c in rows]

    async def classes_getter(self, teacher_id: int) -> ClassOutputDTO:
        result = await ClassModel().get_class_by_id(teacher_id=teacher_id)
        return self._to_output_dto(result)

    async def classes_recommended(
        self,
        current_user_id: int,
        near_lat: float | None = None,
        near_lon: float | None = None,
        limit: int = 8,
    ) -> list[ClassOutputDTO]:
        player = await PlayerModel().get_player_by_user_id(user_id=current_user_id)
        favorite_sport_id = player.favorite_sport_id if player else None
        rows = await ClassModel().recommend_classes(
            favorite_sport_id=favorite_sport_id,
            near_lat=near_lat,
            near_lon=near_lon,
            limit=limit,
        )
        return [self._to_output_dto(c) for c in rows]
