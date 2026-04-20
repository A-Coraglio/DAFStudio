"""chat, chat_participant, chat_message tables

Revision ID: fa1234567890
Revises: e9f012345678
Create Date: 2026-04-20 12:50:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'fa1234567890'
down_revision: Union[str, Sequence[str], None] = 'e9f012345678'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "chat",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("game_id", sa.Integer(), nullable=True),
        sa.Column("name", sa.String(length=100), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.ForeignKeyConstraint(["game_id"], ["game.id"]),
    )
    op.create_index("ix_chat_game_id", "chat", ["game_id"])

    op.create_table(
        "chat_participant",
        sa.Column("chat_id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), primary_key=True),
        sa.ForeignKeyConstraint(["chat_id"], ["chat.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["auth_user.id"]),
    )

    op.create_table(
        "chat_message",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("chat_id", sa.Integer(), nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("content", sa.Text(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.ForeignKeyConstraint(["chat_id"], ["chat.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["auth_user.id"]),
    )
    op.create_index("ix_chat_message_chat_id", "chat_message", ["chat_id"])


def downgrade() -> None:
    op.drop_index("ix_chat_message_chat_id", table_name="chat_message")
    op.drop_table("chat_message")
    op.drop_table("chat_participant")
    op.drop_index("ix_chat_game_id", table_name="chat")
    op.drop_table("chat")
