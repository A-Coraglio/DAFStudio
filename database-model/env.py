from logging.config import fileConfig
import pkgutil
import re
import models
from sqlalchemy import engine_from_config
from sqlalchemy import pool
import os
from alembic import context
from sqlmodel import SQLModel
from sqlmodel.sql.sqltypes import AutoString
from dotenv import load_dotenv

load_dotenv()
# Import every model module so SQLModel.metadata sees the full schema.
for module_info in pkgutil.walk_packages(models.__path__, models.__name__ + "."):
    __import__(f"{module_info.name}")
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# add your model's MetaData object here
# for 'autogenerate' support
# from myapp import mymodel
# target_metadata = mymodel.Base.metadata
target_metadata = SQLModel.metadata

# other values from the config, defined by the needs of env.py,
# can be acquired:
# my_important_option = config.get_main_option("my_important_option")
# ... etc.


def render_item(type_, obj, autogen_context):
    # Map SQLModel AutoString → sa.String
    if type_ == "type" and isinstance(obj, AutoString):
        return f"sa.String(length={obj.length})" 
    return False  

def _resolved_url() -> str:
    """alembic.ini stores the URL with ${DB_*} tokens; the real credentials
    live in .env. Used by both the online and offline modes."""
    url_tokens = {
        "DB_USER": os.environ.get("DB_USER", ""),
        "DB_PASS": os.environ.get("DB_PASS", ""),
        "DB_HOST": os.environ.get("DB_HOST", ""),
        "DB_NAME": os.environ.get("DB_NAME", ""),
    }
    url = config.get_main_option("sqlalchemy.url")
    return re.sub(r"\${(.+?)}", lambda m: url_tokens[m.group(1)], url)  # type: ignore


def run_migrations_offline() -> None:
    """Offline mode: emit the SQL without connecting."""
    context.configure(
        url=_resolved_url(),
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        render_item=render_item,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Online mode: connect and run the migrations."""
    connectable = engine_from_config(
        {**config.get_section(config.config_ini_section), "sqlalchemy.url": _resolved_url()},  # type: ignore
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            render_item=render_item,
        )

        with context.begin_transaction():
            context.run_migrations()
    


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
