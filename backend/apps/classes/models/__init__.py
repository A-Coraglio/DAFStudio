from contextlib import asynccontextmanager

from asyncpg.pool import Pool
from load_database import database_object, DatabaseManager


class GeneralModel:
    _db: DatabaseManager

    def __init__(self):
        self._db = database_object

    @asynccontextmanager
    async def get_db_connection(self):
        connection_pool: Pool = await self._db.get_pool()
        async with connection_pool.acquire() as connection:
            yield connection
