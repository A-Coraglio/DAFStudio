"""player profile names

Revision ID: b2c3d4e5f6g7
Revises: a1b2c3d4e5f6
Create Date: 2026-04-19 12:00:00.000000

Adds first_name / last_name to the player table so the onboarding flow can
collect them in a separate step after register (which is now just email +
password + username).
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b2c3d4e5f6g7'
down_revision: Union[str, Sequence[str], None] = 'a1b2c3d4e5f6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('player', sa.Column('first_name', sa.String(length=50), nullable=True))
    op.add_column('player', sa.Column('last_name', sa.String(length=50), nullable=True))


def downgrade() -> None:
    op.drop_column('player', 'last_name')
    op.drop_column('player', 'first_name')
