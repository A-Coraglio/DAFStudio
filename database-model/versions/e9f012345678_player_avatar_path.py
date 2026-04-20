"""player.avatar_path

Revision ID: e9f012345678
Revises: d8ef90123456
Create Date: 2026-04-20 12:40:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'e9f012345678'
down_revision: Union[str, Sequence[str], None] = 'd8ef90123456'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "player",
        sa.Column("avatar_path", sa.String(length=255), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("player", "avatar_path")
