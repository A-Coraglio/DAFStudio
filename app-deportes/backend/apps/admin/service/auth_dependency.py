from fastapi import Depends

from apps.admin.exceptions.exceptions import AdminForbiddenException
from apps.admin.models.models import AdminModel
from apps.users.service.auth_dependency import get_current_user_id


async def require_admin(
    current_user_id: int = Depends(get_current_user_id),
) -> int:
    """Como get_current_user_id pero exige fila en la tabla `admin`.
    Devuelve el user_id del admin."""
    if not await AdminModel().is_admin(user_id=current_user_id):
        raise AdminForbiddenException()
    return current_user_id
