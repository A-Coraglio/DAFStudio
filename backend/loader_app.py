from contextlib import asynccontextmanager
from pathlib import Path
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apps.games.exceptions.exceptions import AppException
from apps.matchmaking.service.matcher import Matcher
from load_database import database_object
from apps.games.namespaces.routes import router as games_router
from apps.users.namespaces.routes import router as users_router
from apps.sports.namespaces.routes import router as sports_router
from apps.courts.namespaces.routes import router as courts_router
from apps.clubs.namespaces.routes import router as clubs_router
from apps.players.namespaces.routes import router as players_router
from apps.matchmaking.namespaces.routes import router as matchmaking_router
from apps.sport_modes.namespaces.routes import router as sport_modes_router
from apps.chats.namespaces.routes import router as chats_router
from traceback import format_exc


# Interval (seconds) at which the matchmaker sweeps the queue. The queue
# endpoint also runs the matcher opportunistically, so this cron mainly
# catches users who queued alone and a compatible player arrives later.
# 20s is a middle-ground between responsiveness and query load.
MATCHER_INTERVAL_SECONDS = 20


async def _run_matcher_job() -> None:
    try:
        await Matcher().run()
    except Exception:
        # Never let a matcher failure crash the scheduler; log and continue.
        print("[matcher cron] run failed:\n" + format_exc())


@asynccontextmanager
async def lifespan(app: FastAPI):
    await database_object.start_pool()
    scheduler = AsyncIOScheduler()
    scheduler.add_job(
        _run_matcher_job,
        "interval",
        seconds=MATCHER_INTERVAL_SECONDS,
        id="matchmaker",
        max_instances=1,
        coalesce=True,
    )
    scheduler.start()
    try:
        yield
    finally:
        scheduler.shutdown(wait=False)
        await database_object.close_pool()
    
app : FastAPI = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(games_router)
app.include_router(users_router)
app.include_router(sports_router)
app.include_router(courts_router)
app.include_router(clubs_router)
app.include_router(players_router)
app.include_router(matchmaking_router)
app.include_router(sport_modes_router)
app.include_router(chats_router)

# User uploads (avatars, future attachments). Directory is created on demand
# by the upload path — we just mount it so GET /uploads/<file> resolves.
UPLOADS_DIR = Path(__file__).resolve().parent / "uploads"
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")



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