"""auth_user.banned_at + tabla admin_audit_log (área de administración)

Ban de admin: banned_at bloquea login/refresh y cada request autenticado
(expulsión inmediata — el auth_dependency chequea la DB por request).
admin_audit_log registra quién baneó/eliminó/promovió/canceló qué y cuándo.
La tabla `admin` (quién es admin) ya existía en el schema.

Revision ID: d1e2f3a4b5c6
Revises: c0d1e2f3a4b5
Create Date: 2026-07-21 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'd1e2f3a4b5c6'
down_revision: Union[str, Sequence[str], None] = 'c0d1e2f3a4b5'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "auth_user",
        sa.Column("banned_at", sa.DateTime(), nullable=True),
    )
    op.create_table(
        "admin_audit_log",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column(
            "admin_user_id", sa.Integer(), sa.ForeignKey("auth_user.id"),
            nullable=False,
        ),
        sa.Column("action", sa.String(length=30), nullable=False),
        sa.Column("target_type", sa.String(length=10), nullable=False),
        sa.Column("target_id", sa.Integer(), nullable=False),
        sa.Column("detail", sa.String(length=255), nullable=True),
        sa.Column(
            "created_at", sa.DateTime(), nullable=False,
            server_default=sa.text("now()"),
        ),
    )


def downgrade() -> None:
    op.drop_table("admin_audit_log")
    op.drop_column("auth_user", "banned_at")
