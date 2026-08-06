"""add chat_read_state table for per-user unread tracking

Revision ID: fc3456789012
Revises: fb2345678901
Create Date: 2026-05-18 12:00:00.000000

Adds `chat_read_state(chat_id, user_id, last_read_message_id)` — a per-user
read cursor. Lets the chat list show unread counts and the bottom-nav Chats
tab show a badge. Keyed by (chat_id, user_id) instead of extending
chat_participant because game chats have no explicit participant rows.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'fc3456789012'
down_revision: Union[str, Sequence[str], None] = 'fb2345678901'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "chat_read_state",
        sa.Column(
            "chat_id",
            sa.Integer(),
            sa.ForeignKey("chat.id"),
            primary_key=True,
            nullable=False,
        ),
        sa.Column(
            "user_id",
            sa.Integer(),
            sa.ForeignKey("auth_user.id"),
            primary_key=True,
            nullable=False,
        ),
        sa.Column(
            "last_read_message_id",
            sa.Integer(),
            sa.ForeignKey("chat_message.id"),
            nullable=True,
        ),
    )


def downgrade() -> None:
    op.drop_table("chat_read_state")
