from datetime import datetime, timedelta

from apps.lessons.models.ddo import LessonDDO
from apps.lessons.models.models import LessonModel
from apps.lessons.service.dto import (
    BusySlotOutputDTO,
    LessonOutputDTO,
)
from apps.lessons.exceptions.exceptions import LessonValidationException
from apps.classes.models.models import ClassModel
from apps.players.exceptions.exceptions import PlayerNotFoundException
from apps.players.models.models import PlayerModel

MIN_DURATION = timedelta(minutes=30)
MAX_DURATION = timedelta(hours=4)


class AppService:

    def _to_output_dto(self, lesson: LessonDDO) -> LessonOutputDTO:
        return LessonOutputDTO(**lesson.model_dump())

    async def _player_for_user(self, user_id: int):
        player = await PlayerModel().get_player_by_user_id(user_id=user_id)
        if player is None:
            raise PlayerNotFoundException(
                message=f"El usuario {user_id} no tiene perfil de jugador"
            )
        return player

    async def lesson_booker(
        self,
        current_user_id: int,
        teacher_id: int,
        start_time: datetime,
        end_time: datetime,
    ) -> LessonOutputDTO:
        player = await self._player_for_user(current_user_id)
        # 404 if the teacher doesn't exist; also the price source.
        teacher = await ClassModel().get_class_by_id(teacher_id=teacher_id)
        if teacher.user_id == current_user_id:
            raise LessonValidationException(
                message="No podés reservar una clase con vos mismo"
            )
        if end_time <= start_time:
            raise LessonValidationException(
                message="La clase tiene que terminar después de empezar"
            )
        duration = end_time - start_time
        if duration < MIN_DURATION or duration > MAX_DURATION:
            raise LessonValidationException(
                message="La clase tiene que durar entre 30 minutos y 4 horas"
            )
        if start_time <= datetime.now():
            raise LessonValidationException(
                message="La clase tiene que ser en el futuro"
            )
        hours = duration.total_seconds() / 3600
        total_price = round(teacher.price_per_hour * hours, 2)
        # Overlap check + insert run under the teacher row lock.
        lesson_id = await LessonModel().book_atomic(
            teacher_id=teacher_id,
            student_id=player.id,
            start_time=start_time,
            end_time=end_time,
            total_price=total_price,
        )
        lesson = await LessonModel().get_by_id(lesson_id=lesson_id)
        return self._to_output_dto(lesson)

    async def my_lessons_lister(
        self, current_user_id: int
    ) -> list[LessonOutputDTO]:
        player = await self._player_for_user(current_user_id)
        rows = await LessonModel().list_for_student(student_id=player.id)
        return [self._to_output_dto(lesson) for lesson in rows]

    async def lesson_canceller(
        self, current_user_id: int, lesson_id: int
    ) -> LessonOutputDTO:
        player = await self._player_for_user(current_user_id)
        await LessonModel().cancel_atomic(
            lesson_id=lesson_id, student_id=player.id
        )
        lesson = await LessonModel().get_by_id(lesson_id=lesson_id)
        return self._to_output_dto(lesson)

    async def busy_slots_lister(
        self, teacher_id: int
    ) -> list[BusySlotOutputDTO]:
        # 404 first so an empty list always means "free agenda".
        await ClassModel().get_class_by_id(teacher_id=teacher_id)
        rows = await LessonModel().busy_slots(teacher_id=teacher_id)
        return [BusySlotOutputDTO(**slot.model_dump()) for slot in rows]
