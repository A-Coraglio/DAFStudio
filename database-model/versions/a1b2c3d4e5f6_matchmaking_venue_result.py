"""matchmaking, venue and result fields

Revision ID: a1b2c3d4e5f6
Revises: 18150e01fe7e
Create Date: 2026-04-19 00:00:00.000000

Adds:
- auth_user.home_lat / home_lon for default user location.
- player.favorite_sport_id for the sport picked during registration.
- court: owner_id (private courts), nullable club_id, lat/lon, XOR constraint.
- game: court_id, mode, scheduled_at, result_home, result_away.
- game_result_confirmation: per-player result reports for cross-confirmation.
- matchmaking_ticket: queue entries for the matchmaker worker.
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, Sequence[str], None] = '18150e01fe7e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""

    # --- auth_user: default location ---
    op.add_column('auth_user', sa.Column('home_lat', sa.Float(), nullable=True))
    op.add_column('auth_user', sa.Column('home_lon', sa.Float(), nullable=True))

    # --- player: favorite sport ---
    op.add_column(
        'player',
        sa.Column('favorite_sport_id', sa.Integer(), nullable=True),
    )
    op.create_foreign_key(
        'fk_player_favorite_sport',
        source_table='player',
        referent_table='sports',
        local_cols=['favorite_sport_id'],
        remote_cols=['id'],
    )

    # --- court: allow private (user-owned) courts, geo, XOR constraint ---
    op.alter_column('court', 'club_id', existing_type=sa.Integer(), nullable=True)
    op.add_column('court', sa.Column('owner_id', sa.Integer(), nullable=True))
    op.add_column('court', sa.Column('lat', sa.Float(), nullable=True))
    op.add_column('court', sa.Column('lon', sa.Float(), nullable=True))
    op.create_foreign_key(
        'fk_court_owner',
        source_table='court',
        referent_table='auth_user',
        local_cols=['owner_id'],
        remote_cols=['id'],
    )
    op.create_check_constraint(
        'court_club_xor_owner',
        'court',
        '(club_id IS NOT NULL AND owner_id IS NULL) '
        'OR (club_id IS NULL AND owner_id IS NOT NULL)',
    )

    # --- game: mode, court, scheduling, final score ---
    op.add_column('game', sa.Column('court_id', sa.Integer(), nullable=True))
    op.add_column(
        'game',
        sa.Column(
            'mode',
            sa.String(length=20),
            nullable=False,
            server_default='casual',
        ),
    )
    op.add_column('game', sa.Column('scheduled_at', sa.DateTime(), nullable=True))
    op.add_column('game', sa.Column('result_home', sa.Integer(), nullable=True))
    op.add_column('game', sa.Column('result_away', sa.Integer(), nullable=True))
    op.create_foreign_key(
        'fk_game_court',
        source_table='game',
        referent_table='court',
        local_cols=['court_id'],
        remote_cols=['id'],
    )

    # --- game_result_confirmation: per-player reported score ---
    op.create_table(
        'game_result_confirmation',
        sa.Column('game_id', sa.Integer(), nullable=False),
        sa.Column('player_id', sa.Integer(), nullable=False),
        sa.Column('reported_home', sa.Integer(), nullable=False),
        sa.Column('reported_away', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['game_id'], ['game.id']),
        sa.ForeignKeyConstraint(['player_id'], ['player.id']),
        sa.PrimaryKeyConstraint('game_id', 'player_id'),
    )

    # --- matchmaking_ticket: queue entries ---
    op.create_table(
        'matchmaking_ticket',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('sport_id', sa.Integer(), nullable=False),
        sa.Column('max_radius_km', sa.Float(), nullable=False),
        sa.Column('origin_lat', sa.Float(), nullable=False),
        sa.Column('origin_lon', sa.Float(), nullable=False),
        sa.Column('window_start', sa.DateTime(), nullable=False),
        sa.Column('window_end', sa.DateTime(), nullable=False),
        sa.Column(
            'status',
            sa.String(length=20),
            nullable=False,
            server_default='waiting',
        ),
        sa.Column('matched_game_id', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['auth_user.id']),
        sa.ForeignKeyConstraint(['sport_id'], ['sports.id']),
        sa.ForeignKeyConstraint(['matched_game_id'], ['game.id']),
        sa.PrimaryKeyConstraint('id'),
    )
    op.create_index(
        op.f('ix_matchmaking_ticket_id'), 'matchmaking_ticket', ['id'], unique=False
    )
    op.create_index(
        op.f('ix_matchmaking_ticket_user_id'),
        'matchmaking_ticket',
        ['user_id'],
        unique=False,
    )
    op.create_index(
        op.f('ix_matchmaking_ticket_sport_id'),
        'matchmaking_ticket',
        ['sport_id'],
        unique=False,
    )


def downgrade() -> None:
    """Downgrade schema."""

    op.drop_index(op.f('ix_matchmaking_ticket_sport_id'), table_name='matchmaking_ticket')
    op.drop_index(op.f('ix_matchmaking_ticket_user_id'), table_name='matchmaking_ticket')
    op.drop_index(op.f('ix_matchmaking_ticket_id'), table_name='matchmaking_ticket')
    op.drop_table('matchmaking_ticket')

    op.drop_table('game_result_confirmation')

    op.drop_constraint('fk_game_court', 'game', type_='foreignkey')
    op.drop_column('game', 'result_away')
    op.drop_column('game', 'result_home')
    op.drop_column('game', 'scheduled_at')
    op.drop_column('game', 'mode')
    op.drop_column('game', 'court_id')

    op.drop_constraint('court_club_xor_owner', 'court', type_='check')
    op.drop_constraint('fk_court_owner', 'court', type_='foreignkey')
    op.drop_column('court', 'lon')
    op.drop_column('court', 'lat')
    op.drop_column('court', 'owner_id')
    op.alter_column('court', 'club_id', existing_type=sa.Integer(), nullable=False)

    op.drop_constraint('fk_player_favorite_sport', 'player', type_='foreignkey')
    op.drop_column('player', 'favorite_sport_id')

    op.drop_column('auth_user', 'home_lon')
    op.drop_column('auth_user', 'home_lat')
