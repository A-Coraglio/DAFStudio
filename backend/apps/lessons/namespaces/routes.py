from fastapi import APIRouter, Depends, Query

from apps.lessons.service.dto import (
    BookLessonInputDTO,
    BusySlotOutputDTO,
    LessonOutputDTO,
)
from apps.lessons.service.appservice import AppService
from apps.users.service.auth_dependency import get_current_user_id

router: APIRouter = APIRouter(prefix="/api")


@router.post("/lessons/", responses={
    200: {"model": LessonOutputDTO, "description": "The booked lesson"},
    400: {"description": "Invalid slot (past, inverted, absurd duration, self)"},
    401: {"description": "Unauthorized"},
    404: {"description": "Teacher or player not found"},
    409: {"description": "The teacher already has a lesson in that slot"},
})
async def book_lesson(
    body: BookLessonInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().lesson_booker(
        current_user_id=current_user_id,
        teacher_id=body.teacher_id,
        start_time=body.start_time,
        end_time=body.end_time,
        sport_id=body.sport_id,
    )


@router.get("/lessons/mine/", responses={
    200: {
        "model": list[LessonOutputDTO],
        "description": "The caller's lessons: upcoming first, then past ones",
    },
    401: {"description": "Unauthorized"},
})
async def my_lessons(
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().my_lessons_lister(current_user_id=current_user_id)


@router.get("/lessons/teaching/", responses={
    200: {
        "model": list[LessonOutputDTO],
        "description": "Agenda del profe: pendientes primero, con nombre del alumno",
    },
    401: {"description": "Unauthorized"},
    403: {"description": "No sos profesor"},
})
async def teaching_lessons(
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().teaching_lister(current_user_id=current_user_id)


@router.post("/lessons/{lesson_id}/confirm/", responses={
    200: {"model": LessonOutputDTO, "description": "Clase confirmada por el profe"},
    401: {"description": "Unauthorized"},
    404: {"description": "Clase inexistente (o no sos su profe)"},
    409: {"description": "La clase no está pendiente"},
})
async def confirm_lesson(
    lesson_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().teacher_status_setter(
        current_user_id=current_user_id, lesson_id=lesson_id, action="confirm"
    )


@router.post("/lessons/{lesson_id}/reject/", responses={
    200: {"model": LessonOutputDTO, "description": "Clase rechazada por el profe"},
    401: {"description": "Unauthorized"},
    404: {"description": "Clase inexistente (o no sos su profe)"},
    409: {"description": "La clase no está pendiente"},
})
async def reject_lesson(
    lesson_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().teacher_status_setter(
        current_user_id=current_user_id, lesson_id=lesson_id, action="reject"
    )


@router.post("/lessons/{lesson_id}/teacher-cancel/", responses={
    200: {"model": LessonOutputDTO, "description": "Clase cancelada por el profe"},
    401: {"description": "Unauthorized"},
    404: {"description": "Clase inexistente (o no sos su profe)"},
    409: {"description": "La clase ya pasó o ya estaba cancelada"},
})
async def teacher_cancel_lesson(
    lesson_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().teacher_status_setter(
        current_user_id=current_user_id, lesson_id=lesson_id, action="cancel"
    )


@router.get("/lessons/busy/", responses={
    200: {
        "model": list[BusySlotOutputDTO],
        "description": "Upcoming occupied slots of a teacher's agenda",
    },
    401: {"description": "Unauthorized"},
    404: {"description": "Teacher not found"},
})
async def teacher_busy_slots(
    teacher_id: int = Query(description="Teacher whose agenda to check"),
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().busy_slots_lister(teacher_id=teacher_id)


@router.post("/lessons/{lesson_id}/cancel/", responses={
    200: {"model": LessonOutputDTO, "description": "The cancelled lesson"},
    401: {"description": "Unauthorized"},
    404: {"description": "Lesson not found (or not the caller's)"},
    409: {"description": "Already cancelled, or the lesson already happened"},
})
async def cancel_lesson(
    lesson_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AppService().lesson_canceller(
        current_user_id=current_user_id, lesson_id=lesson_id
    )
