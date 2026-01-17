import asyncpg
import os
from asyncpg.pool import Pool
from dotenv import load_dotenv

load_dotenv()


class DatabaseManager:
    _pool: Pool = None

    def __init__(self) -> None:
        self._pool = None

    async def start_pool(self) -> None:
        if self._pool is None:
            database_pool = await asyncpg.create_pool(
                host=os.environ.get("DB_HOST", ""),
                port=os.environ.get("DB_PORT", ""),
                user=os.environ.get("DB_USER", ""),
                password=os.environ.get("DB_PASS", ""),
                database=os.environ.get("DB_NAME", ""),
                min_size=int(os.environ.get("DB_POOL_SIZE", 1)),
                max_size=int(os.environ.get("DB_MAX_OVERFLOW", 2)),
            )
            self._pool = database_pool

    async def get_pool(self):
        if self._pool:
            return self._pool
        raise Exception("no db connection")

    async def close_pool(self):
        if self._pool:
            await self._pool.close()
            self._pool = None


database_object = DatabaseManager()