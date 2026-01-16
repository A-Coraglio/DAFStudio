from fastapi import FastAPI
from apps.games.namespaces.routes import router as games_router

app : FastAPI = FastAPI()


app.include_router(games_router)
