"""auth_user.deleted_at (soft-delete de cuenta)

Account deletion is a soft-delete: the row stays (games, messages and other
players' histories keep their FKs intact) but deleted_at is stamped and the
personal fields are anonymized by the backend. Login lookups filter
`deleted_at IS NULL`, which also frees the email/username for re-registration
after the anonymization rename.

Revision ID: f7a8b9c0d1e2
Revises: e6f7a8b9c0d1
Create Date: 2026-07-21 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'f7a8b9c0d1e2'
down_revision: Union[str, Sequence[str], None] = 'e6f7a8b9c0d1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "auth_user",
        sa.Column("deleted_at", sa.DateTime(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("auth_user", "deleted_at")
