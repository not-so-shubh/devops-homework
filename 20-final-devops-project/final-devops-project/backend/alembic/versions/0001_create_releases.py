"""Create releases table."""

from alembic import op
import sqlalchemy as sa


revision = "0001_create_releases"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "releases",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("service", sa.String(length=80), nullable=False),
        sa.Column("version", sa.String(length=40), nullable=False),
        sa.Column("environment", sa.String(length=20), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("owner", sa.String(length=80), nullable=False),
        sa.Column("notes", sa.String(length=280), nullable=False, server_default=""),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_releases_service", "releases", ["service"])
    op.create_index("ix_releases_environment", "releases", ["environment"])
    op.create_index("ix_releases_status", "releases", ["status"])


def downgrade() -> None:
    op.drop_table("releases")
