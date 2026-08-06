from apps.teachers.exceptions.exceptions import (
    TeacherNotFoundException,
    TeacherRequestException,
)
from apps.teachers.models.models import TeacherModel
from apps.teachers.service.dto import (
    MyTeacherOutputDTO,
    TeacherApplyInputDTO,
    TeacherRequestOutputDTO,
    TeacherStatusOutputDTO,
    UpdateTeacherInputDTO,
)
from apps.sports.models.models import SportModel


class AppService:

    async def _validate_sports(self, sport_ids: list[int]) -> None:
        if not sport_ids:
            raise TeacherRequestException(
                message="Elegí al menos un deporte para enseñar"
            )
        valid = {s.id for s in await SportModel().list_sports()}
        if any(sid not in valid for sid in sport_ids):
            raise TeacherRequestException(message="Hay un deporte inválido")

    async def status_getter(self, user_id: int) -> TeacherStatusOutputDTO:
        teacher = await TeacherModel().get_teacher_by_user_id(user_id=user_id)
        request = await TeacherModel().get_latest_request(user_id=user_id)
        return TeacherStatusOutputDTO(
            is_teacher=teacher is not None,
            teacher=(
                MyTeacherOutputDTO(**teacher.model_dump()) if teacher else None
            ),
            request=(
                TeacherRequestOutputDTO(**request.model_dump())
                if request else None
            ),
        )

    async def applier(
        self, user_id: int, data: TeacherApplyInputDTO
    ) -> TeacherStatusOutputDTO:
        if not data.bio.strip():
            raise TeacherRequestException(
                message="Contanos algo de vos en la bio"
            )
        await self._validate_sports(data.sport_ids)
        if await TeacherModel().get_teacher_by_user_id(user_id=user_id):
            raise TeacherRequestException(
                message="Ya sos profesor", error_code=409
            )
        latest = await TeacherModel().get_latest_request(user_id=user_id)
        if latest is not None and latest.status == "pending":
            raise TeacherRequestException(
                message="Ya tenés una solicitud pendiente", error_code=409
            )
        await TeacherModel().create_request(
            user_id=user_id,
            bio=data.bio.strip(),
            price_per_hour=data.price_per_hour,
            experience_years=data.experience_years,
            sport_ids=data.sport_ids,
        )
        return await self.status_getter(user_id=user_id)

    async def me_updater(
        self, user_id: int, data: UpdateTeacherInputDTO
    ) -> MyTeacherOutputDTO:
        teacher = await TeacherModel().get_teacher_by_user_id(user_id=user_id)
        if teacher is None:
            raise TeacherNotFoundException()
        if data.sport_ids is not None:
            await self._validate_sports(data.sport_ids)
        if data.bio is not None and not data.bio.strip():
            raise TeacherRequestException(message="La bio no puede quedar vacía")
        await TeacherModel().update_teacher(
            teacher_id=teacher.id,
            bio=data.bio.strip() if data.bio else None,
            price_per_hour=data.price_per_hour,
            experience_years=data.experience_years,
            sport_ids=data.sport_ids,
        )
        updated = await TeacherModel().get_teacher_by_user_id(user_id=user_id)
        return MyTeacherOutputDTO(**updated.model_dump())  # type: ignore
