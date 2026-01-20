from contextlib import asynccontextmanager
from fastapi import FastAPI
from load_database import database_object
from apps.games.namespaces.routes import router as games_router



@asynccontextmanager
async def lifespan(app: FastAPI):
    await database_object.start_pool()
    yield
    await database_object.close_pool()
    
app : FastAPI = FastAPI(lifespan=lifespan)


app.include_router(games_router)
