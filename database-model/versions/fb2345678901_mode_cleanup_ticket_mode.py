"""collapse game mode 'matchmaking' into 'competitive' and add matchmaking_ticket.mode

Revision ID: fb2345678901
Revises: fa1234567890
Create Date: 2026-04-21 10:00:00.000000

Rationale: 'matchmaking' was both a game-mode value AND a discovery mechanism,
which made filtering ambiguous. Now mode ∈ {casual, competitive} on both the
game and the ticket; how the game came into existence is a separate concern.
Existing games with mode='matchmaking' were already awarding ELO, so they
collapse into 'competitive' without behavioral change.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'fb2345678901'
down_revision: Union[str, Sequence[str], None] = 'fa1234567890'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute(
        "UPDATE game SET mode = 'competitive' WHERE mode = 'matchmaking'"
    )
    op.add_column(
        "matchmaking_ticket",
        sa.Column(
            "mode",
            sa.String(length=20),
            nullable=False,
            server_default="competitive",
        ),
    )


def downgrade() -> None:
    op.drop_column("matchmaking_ticket", "mode")
