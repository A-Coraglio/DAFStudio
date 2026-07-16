"""tournament level + location (lat/lon)

Adds the fields needed to recommend tournaments by the user's level and by
real distance: a self-reported `level` and a `lat`/`lon` pair. Location lives
on the tournament itself (not only via the club) so tournaments without a club
can still be placed on the map.

Revision ID: f1e2d3c4b5a6
Revises: fd4567890123
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'f1e2d3c4b5a6'
down_revision: Union[str, Sequence[str], None] = 'fd4567890123'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "tournament", sa.Column("level", sa.String(length=20), nullable=True)
    )
    op.add_column("tournament", sa.Column("lat", sa.Float(), nullable=True))
    op.add_column("tournament", sa.Column("lon", sa.Float(), nullable=True))


def downgrade() -> None:
    op.drop_column("tournament", "lon")
    op.drop_column("tournament", "lat")
    op.drop_column("tournament", "level")
