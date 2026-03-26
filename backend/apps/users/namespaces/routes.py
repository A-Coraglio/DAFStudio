from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from apps.users.service.dto import (
    RegisterInputDTO,
    LoginInputDTO,
    UpdateUserInputDTO,
    UserOutputDTO,
    TokenOutputDTO
)
from apps.users.service.authservice import AuthService

router: APIRouter = APIRouter(prefix="/api/auth")

@router.post("/register/", responses={
    200: {
        "model": UserOutputDTO,
        "description": "Created user"
    },
    400: {
        "description": "Invalid data"
    }
})
async def registers(body: RegisterInputDTO):

    user: UserOutputDTO | None = await AuthService().users_register(data=body)
    if user is None:
        raise HTTPException(status_code=400, detail="Invalid data")

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

    token: TokenOutputDTO | None = await AuthService().users_login(data=body)
    if token is None:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return JSONResponse(status_code=200, content=token.model_dump())


@router.get("/users/{user_id}/", responses={
    200: {
        "model": UserOutputDTO,
        "description": "User instance"
    },
    404: {
        "description": "User not found"
    }
})
async def get_users(user_id: int):

    user: UserOutputDTO | None = await AuthService().users_getter(user_id=user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return user

@router.put("/users/{user_id}/", responses={
    200: {
        "model": UserOutputDTO,
        "description": "Updated user"
    },
    404: {
        "description": "User not found"
    }
})
async def update_users(user_id: int, body: UpdateUserInputDTO):

    user: UserOutputDTO | None = await AuthService().users_updater(user_id=user_id, data=body)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    return user


@router.delete("/users/{user_id}/", responses={
    200: {
        "description": "Deleted user id"
    },
    404: {
        "description": "User not found"
    }
})
async def delete_users(user_id: int):

    deleted_id: int | None = await AuthService().users_deleter(user_id=user_id)
    if deleted_id is None:
        raise HTTPException(status_code=404, detail="User not found")

    return {"deleted_id": deleted_id}
