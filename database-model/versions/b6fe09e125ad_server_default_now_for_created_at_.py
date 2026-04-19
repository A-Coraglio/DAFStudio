"""server default now for created_at columns

Revision ID: b6fe09e125ad
Revises: b2c3d4e5f6g7
Create Date: 2026-04-19 23:19:50.362836

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b6fe09e125ad'
down_revision: Union[str, Sequence[str], None] = 'b2c3d4e5f6g7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


TABLES_WITH_CREATED_AT = (
    "auth_user",
    "lesson",
    "matchmaking_ticket",
    "game_player",
    "game",
    "game_result_confirmation",
    "tournament_participant",
)


def upgrade() -> None:
    for table in TABLES_WITH_CREATED_AT:
        op.alter_column(
            table,
            "created_at",
            server_default=sa.text("now()"),
            existing_type=sa.DateTime(),
            existing_nullable=False,
        )


def downgrade() -> None:
    for table in TABLES_WITH_CREATED_AT:
        op.alter_column(
            table,
            "created_at",
            server_default=None,
            existing_type=sa.DateTime(),
            existing_nullable=False,
        )
