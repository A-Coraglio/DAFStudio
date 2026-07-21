"""auth_user.has_password

Accounts provisioned via Google sign-in get a random password hash the user
never saw. Since changing a password now requires knowing the current one,
those accounts need a flag saying "no usable password yet": has_password=false
lets them SET a first password without providing the current one (flips to
true afterwards).

Existing rows default to true — accounts created before Google sign-in all
have a real password. Google accounts created before this migration also get
true (indistinguishable); they can use the future email-reset flow.

Revision ID: e6f7a8b9c0d1
Revises: d5e6f7a8b9c0
Create Date: 2026-07-20 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'e6f7a8b9c0d1'
down_revision: Union[str, Sequence[str], None] = 'd5e6f7a8b9c0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "auth_user",
        sa.Column(
            "has_password",
            sa.Boolean(),
            nullable=False,
            server_default=sa.true(),
        ),
    )


def downgrade() -> None:
    op.drop_column("auth_user", "has_password")
