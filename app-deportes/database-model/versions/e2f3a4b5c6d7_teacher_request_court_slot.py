"""teacher_request (cola de "quiero ser profe") + court_slot (turnos)

Profesores por aprobación de admin: el jugador solicita con su perfil
propuesto; aprobar crea teacher + teacher_sport. Turnos de cancha: el club
los crea/quita/bloquea y los jugadores reservan los libres.

Revision ID: e2f3a4b5c6d7
Revises: d1e2f3a4b5c6
Create Date: 2026-07-21 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'e2f3a4b5c6d7'
down_revision: Union[str, Sequence[str], None] = 'd1e2f3a4b5c6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "teacher_request",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "user_id", sa.Integer(), sa.ForeignKey("auth_user.id"),
            nullable=False,
        ),
        sa.Column("bio", sa.String(), nullable=False),
        sa.Column("price_per_hour", sa.Float(), nullable=False),
        sa.Column("experience_years", sa.Integer(), nullable=True),
        sa.Column("sport_ids_csv", sa.String(length=100), nullable=False),
        sa.Column(
            "status", sa.String(length=10), nullable=False,
            server_default="pending",
        ),
        sa.Column(
            "created_at", sa.DateTime(), nullable=False,
            server_default=sa.text("now()"),
        ),
    )
    op.create_table(
        "court_slot",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "court_id", sa.Integer(), sa.ForeignKey("court.id"),
            nullable=False,
        ),
        sa.Column("start_time", sa.DateTime(), nullable=False),
        sa.Column("end_time", sa.DateTime(), nullable=False),
        sa.Column(
            "status", sa.String(length=10), nullable=False,
            server_default="free",
        ),
        sa.Column(
            "booked_by_player_id", sa.Integer(), sa.ForeignKey("player.id"),
            nullable=True,
        ),
        sa.Column(
            "created_at", sa.DateTime(), nullable=False,
            server_default=sa.text("now()"),
        ),
    )
    op.create_index(
        "ix_court_slot_court_start", "court_slot", ["court_id", "start_time"]
    )


def downgrade() -> None:
    op.drop_index("ix_court_slot_court_start", table_name="court_slot")
    op.drop_table("court_slot")
    op.drop_table("teacher_request")
