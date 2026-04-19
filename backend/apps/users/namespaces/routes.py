from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from apps.users.service.dto import (
    RegisterInputDTO,
    LoginInputDTO,
    UpdateUserInputDTO,
    UserOutputDTO,
    TokenOutputDTO
)
from apps.users.service.authservice import AuthService
from apps.users.service.auth_dependency import get_current_user_id
from apps.users.exceptions.exceptions import ForbiddenException

router: APIRouter = APIRouter(prefix="/api/auth")


@router.post("/register/", responses={
    200: {
        "model": UserOutputDTO,
        "description": "Created user"
    },
    409: {
        "description": "Email already registered"
    }
})
async def registers(body: RegisterInputDTO):
    user: UserOutputDTO = await AuthService().users_register(data=body)
    return JSONResponse(status_code=200, content=user.model_dump())


@router.post("/login/", responses={
    200: {
        "model": TokenOutputDTO,
        "description": "JWT token"
    },
    401: {
        "description": "Invalid credentials"
    }
})
async def logins(body: LoginInputDTO):
    token: TokenOutputDTO = await AuthService().users_login(data=body)
    return JSONResponse(status_code=200, content=token.model_dump())


@router.get("/users/{user_id}/", responses={
    200: {
        "model": UserOutputDTO,
        "description": "User instance"
    },
    401: {
        "description": "Unauthorized"
    },
    404: {
        "description": "User not found"
    }
})
async def get_users(
    user_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    return await AuthService().users_getter(user_id=user_id)


@router.put("/users/{user_id}/", responses={
    200: {
        "model": UserOutputDTO,
        "description": "Updated user"
    },
    401: {
        "description": "Unauthorized"
    },
    403: {
        "description": "Cannot modify another user"
    },
    404: {
        "description": "User not found"
    }
})
async def update_users(
    user_id: int,
    body: UpdateUserInputDTO,
    current_user_id: int = Depends(get_current_user_id),
):
    if user_id != current_user_id:
        raise ForbiddenException(message="Cannot modify another user")
    return await AuthService().users_updater(user_id=user_id, data=body)


@router.delete("/users/{user_id}/", responses={
    200: {
        "description": "Deleted user id"
    },
    401: {
        "description": "Unauthorized"
    },
    403: {
        "description": "Cannot delete another user"
    },
    404: {
        "description": "User not found"
    }
})
async def delete_users(
    user_id: int,
    current_user_id: int = Depends(get_current_user_id),
):
    if user_id != current_user_id:
        raise ForbiddenException(message="Cannot delete another user")
    deleted_id: int = await AuthService().users_deleter(user_id=user_id)
    return {"deleted_id": deleted_id}
