"""game_player.position: chosen slot within the game

Players can now pick WHERE they play (Playtomic-style): position is a slot
index 0..max_players-1; the first half of the slots is the home side, the
rest is away. Nullable — players who join without choosing (matchmaking,
legacy rows) keep NULL and are balanced by join order at settle time.

Revision ID: d5e6f7a8b9c0
Revises: c4d5e6f7a8b9
Create Date: 2026-07-16 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd5e6f7a8b9c0'
down_revision: Union[str, Sequence[str], None] = 'c4d5e6f7a8b9'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'game_player',
        sa.Column('position', sa.Integer(), nullable=True),
    )
    # One player per slot; NULLs (no chosen position) don't collide.
    op.create_index(
        'uq_game_player_position',
        'game_player',
        ['game_id', 'position'],
        unique=True,
        postgresql_where=sa.text('position IS NOT NULL'),
    )


def downgrade() -> None:
    op.drop_index('uq_game_player_position', table_name='game_player')
    op.drop_column('game_player', 'position')
