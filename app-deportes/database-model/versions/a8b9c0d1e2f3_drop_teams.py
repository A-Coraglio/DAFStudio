"""Drop unused teams schema (team, team_player, game_player.team_id)

Equipos nunca se implementaron: `game_player.team_id` siempre fue NULL (el
split home/away usa position/orden de join) y `team`/`team_player` no tienen
ni código ni datos. Decisión 2026-07-21: limpiar en vez de implementar — si
algún día hay equipos persistentes, el schema se rediseña desde cero.

Revision ID: a8b9c0d1e2f3
Revises: f7a8b9c0d1e2
Create Date: 2026-07-21 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'a8b9c0d1e2f3'
down_revision: Union[str, Sequence[str], None] = 'f7a8b9c0d1e2'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Order matters: team_player and game_player.team_id reference team.
    op.drop_table("team_player")
    op.drop_column("game_player", "team_id")
    op.drop_table("team")


def downgrade() -> None:
    op.create_table(
        "team",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("name", sa.String(length=50), nullable=False),
        sa.Column(
            "sport_id", sa.Integer(), sa.ForeignKey("sports.id"),
            nullable=False,
        ),
    )
    op.create_table(
        "team_player",
        sa.Column(
            "team_id", sa.Integer(), sa.ForeignKey("team.id"),
            primary_key=True,
        ),
        sa.Column(
            "player_id", sa.Integer(), sa.ForeignKey("player.id"),
            primary_key=True,
        ),
    )
    op.add_column(
        "game_player",
        sa.Column(
            "team_id", sa.Integer(), sa.ForeignKey("team.id"), nullable=True
        ),
    )
