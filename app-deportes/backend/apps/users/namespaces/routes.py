from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from apps.users.service.dto import (
    RegisterInputDTO,
    LoginInputDTO,
    GoogleLoginInputDTO,
    RefreshInputDTO,
    UpdateUserInputDTO,
    UserOutputDTO,
    TokenOutputDTO
)
from apps.users.service.authservice import AuthService
from apps.users.service.auth_dependency import get_current_user_id
from apps.users.exceptions.exceptions import ForbiddenException
from apps.common.rate_limit import rate_limit

router: APIRouter = APIRouter(prefix="/api/auth")

# Brute-force dampers, per client IP. Generous for humans, hostile for scripts.
_register_limiter = rate_limit(max_calls=5, per_seconds=60)
_login_limiter = rate_limit(max_calls=10, per_seconds=60)


@router.post("/register/", dependencies=[Depends(_register_limiter)], responses={
    200: {
        "model": UserOutputDTO,
        "description": "Created user"
    },
    409: {
        "description": "Email already registered"
    },
    429: {
        "description": "Too many attempts"
    }
})
async def registers(body: RegisterInputDTO):
    user: UserOutputDTO = await AuthService().users_register(data=body)
    return JSONResponse(status_code=200, content=user.model_dump())


@router.post("/login/", dependencies=[Depends(_login_limiter)], responses={
    200: {
        "model": TokenOutputDTO,
        "description": "JWT token"
    },
    401: {
        "description": "Invalid credentials"
    },
    429: {
        "description": "Too many attempts"
    }
})
async def logins(body: LoginInputDTO):
    token: TokenOutputDTO = await AuthService().users_login(data=body)
    return JSONResponse(status_code=200, content=token.model_dump())


@router.post("/google/", dependencies=[Depends(_login_limiter)], responses={
    200: {"model": TokenOutputDTO, "description": "JWT token after Google sign-in"},
    401: {"description": "Invalid Google token"},
    429: {"description": "Too many attempts"},
    503: {"description": "Google sign-in not configured on the server"},
})
async def login_with_google(body: GoogleLoginInputDTO):
    """Exchange a Google `id_token` (obtained by the client via the native
    Google Sign-In SDK) for one of our JWTs. Creates the auth_user + player
    on first sign-in, then logs in normally on subsequent sign-ins."""
    token: TokenOutputDTO = await AuthService().users_login_with_google(
        id_token=body.id_token
    )
    return JSONResponse(status_code=200, content=token.model_dump())


@router.post("/refresh/", dependencies=[Depends(_login_limiter)], responses={
    200: {"model": TokenOutputDTO, "description": "New access+refresh pair"},
    401: {"description": "Refresh token invalid or expired"},
    429: {"description": "Too many attempts"},
})
async def refresh(body: RefreshInputDTO):
    """Rotates a refresh token into a fresh access+refresh pair, so sessions
    survive the 60-minute access-token expiry without re-login."""
    token: TokenOutputDTO = await AuthService().users_refresh(
        refresh_token=body.refresh_token
    )
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
        raise ForbiddenException(message="No podés modificar otra cuenta")
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
        raise ForbiddenException(message="No podés eliminar otra cuenta")
    deleted_id: int = await AuthService().users_deleter(user_id=user_id)
    return {"deleted_id": deleted_id}
