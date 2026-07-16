"""teacher_sport composite PK (allow multiple sports per teacher)

The live DB kept a single-column primary key on teacher_sport(teacher_id),
which limited each teacher to one sport. The SQLModel model already declares a
composite (teacher_id, sport_id) key; this migration brings the DB in line so a
teacher can teach several sports.

Revision ID: a2b3c4d5e6f7
Revises: f1e2d3c4b5a6
Create Date: 2026-07-15 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op


revision: str = 'a2b3c4d5e6f7'
down_revision: Union[str, Sequence[str], None] = 'f1e2d3c4b5a6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.drop_constraint("teacher_sport_pkey", "teacher_sport", type_="primary")
    op.create_primary_key(
        "teacher_sport_pkey", "teacher_sport", ["teacher_id", "sport_id"]
    )


def downgrade() -> None:
    # Collapsing back to a single-column key would fail if any teacher has more
    # than one sport; keep the composite key on downgrade only when safe.
    op.drop_constraint("teacher_sport_pkey", "teacher_sport", type_="primary")
    op.create_primary_key(
        "teacher_sport_pkey", "teacher_sport", ["teacher_id"]
    )
