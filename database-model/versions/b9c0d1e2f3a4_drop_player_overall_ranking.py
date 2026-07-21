"""Drop player.ranking_points (overall legacy)

El ranking real es player_sport_stat.ranking_points (ELO por deporte, base
1000). El overall de player arrancaba en 0 y acumulaba deltas de TODOS los
deportes — nunca fue comparable con el ELO y desde el 2026-07-21 nadie lo
lee (búsqueda, perfiles y stats pasaron a player_sport_stat). Se droppea la
columna y la doble escritura del ELO.

Revision ID: b9c0d1e2f3a4
Revises: a8b9c0d1e2f3
Create Date: 2026-07-21 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'b9c0d1e2f3a4'
down_revision: Union[str, Sequence[str], None] = 'a8b9c0d1e2f3'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_column("player", "ranking_points")


def downgrade() -> None:
    # Los valores viejos no se recuperan — la columna vuelve en 0 como nació.
    op.add_column(
        "player",
        sa.Column(
            "ranking_points", sa.Integer(), nullable=False,
            server_default="0",
        ),
    )
