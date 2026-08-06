"""add updated_at to chat_message for own-message editing

Revision ID: fd4567890123
Revises: fc3456789012
Create Date: 2026-07-13 12:00:00.000000

Nullable timestamp set by the backend whenever the author edits their
message. NULL means "never edited" — the UI shows an "editado" hint when
it's present.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'fd4567890123'
down_revision: Union[str, Sequence[str], None] = 'fc3456789012'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "chat_message",
        sa.Column("updated_at", sa.DateTime(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("chat_message", "updated_at")
