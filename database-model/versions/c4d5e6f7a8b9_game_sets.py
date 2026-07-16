"""game + confirmation set scores

Set-based sports (pádel, tenis, vóley) report several sets. We keep
result_home/result_away as the number of SETS won (so ELO, outcome and history
stay unchanged) and store the per-set detail as a compact string like
"6-4,6-3" on both the game and each player's confirmation.

Revision ID: c4d5e6f7a8b9
Revises: b3c4d5e6f7a8
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'c4d5e6f7a8b9'
down_revision: Union[str, Sequence[str], None] = 'b3c4d5e6f7a8'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("game", sa.Column("sets", sa.String(length=100), nullable=True))
    op.add_column(
        "game_result_confirmation",
        sa.Column("sets", sa.String(length=100), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("game_result_confirmation", "sets")
    op.drop_column("game", "sets")
