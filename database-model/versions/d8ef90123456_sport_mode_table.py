"""sport_mode table (scaffold for sub-modalities)

Revision ID: d8ef90123456
Revises: c7def8901234
Create Date: 2026-04-20 12:30:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd8ef90123456'
down_revision: Union[str, Sequence[str], None] = 'c7def8901234'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "sport_mode",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("sport_id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=50), nullable=False),
        sa.Column("max_players_per_team", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["sport_id"], ["sports.id"]),
    )
    op.create_index("ix_sport_mode_sport_id", "sport_mode", ["sport_id"])


def downgrade() -> None:
    op.drop_index("ix_sport_mode_sport_id", table_name="sport_mode")
    op.drop_table("sport_mode")
