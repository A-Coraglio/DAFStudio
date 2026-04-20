"""matchmaking ticket proposed_at timestamp

Revision ID: c7def8901234
Revises: b6fe09e125ad
Create Date: 2026-04-20 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'c7def8901234'
down_revision: Union[str, Sequence[str], None] = 'b6fe09e125ad'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "matchmaking_ticket",
        sa.Column("proposed_at", sa.DateTime(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("matchmaking_ticket", "proposed_at")
