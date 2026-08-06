"""lesson.sport_id (deporte de la clase)

La reserva ahora registra QUÉ deporte se va a practicar (el profe puede
enseñar varios). Nullable: las lecciones previas quedan sin deporte y el
booking lo manda opcionalmente. court_id sigue afuera hasta que exista un
flujo de elegir cancha para clases.

Revision ID: c0d1e2f3a4b5
Revises: b9c0d1e2f3a4
Create Date: 2026-07-21 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'c0d1e2f3a4b5'
down_revision: Union[str, Sequence[str], None] = 'b9c0d1e2f3a4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "lesson",
        sa.Column(
            "sport_id", sa.Integer(), sa.ForeignKey("sports.id"),
            nullable=True,
        ),
    )


def downgrade() -> None:
    op.drop_column("lesson", "sport_id")
