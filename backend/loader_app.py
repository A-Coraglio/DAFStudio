from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from apps.games.exceptions.exceptions import AppException
from load_database import database_object
from apps.games.namespaces.routes import router as games_router
from apps.users.namespaces.routes import router as users_router
from traceback import format_exc

@asynccontextmanager
async def lifespan(app: FastAPI):
    await database_object.start_pool()
    yield
    await database_object.close_pool()
    
app : FastAPI = FastAPI(lifespan=lifespan)


app.include_router(games_router)
app.include_router(users_router)



@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    try:
        response = await call_next(request)
        return response
    except Exception as e:
        if isinstance(e, AppException):
            return JSONResponse({
                "type_exception" : e.__class__.__name__,
                "error" : str(e),
                "trace" : format_exc()
            }, status_code=e.error_code)
        raise