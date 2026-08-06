"""player_sport_stat: per-sport ranking

Ranking (and, by extension, the W/L tally) becomes per-sport instead of one
number per player: a player can be strong at pádel and a beginner at tenis.
The legacy player.ranking_points column is kept as a denormalised "overall"
cache used only for the players-search ordering.

Revision ID: b3c4d5e6f7a8
Revises: a2b3c4d5e6f7
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b3c4d5e6f7a8'
down_revision: Union[str, Sequence[str], None] = 'a2b3c4d5e6f7'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'player_sport_stat',
        sa.Column('player_id', sa.Integer(), nullable=False),
        sa.Column('sport_id', sa.Integer(), nullable=False),
        sa.Column(
            'ranking_points', sa.Integer(), nullable=False,
            server_default='1000',
        ),
        sa.ForeignKeyConstraint(['player_id'], ['player.id']),
        sa.ForeignKeyConstraint(['sport_id'], ['sports.id']),
        sa.PrimaryKeyConstraint('player_id', 'sport_id'),
    )


def downgrade() -> None:
    op.drop_table('player_sport_stat')
