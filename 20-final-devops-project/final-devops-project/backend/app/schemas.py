from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


Environment = Literal["development", "staging", "production"]
ReleaseStatus = Literal["planned", "deploying", "healthy", "failed", "rolled-back"]


class ReleaseCreate(BaseModel):
    service: str = Field(min_length=2, max_length=80)
    version: str = Field(min_length=1, max_length=40)
    environment: Environment
    status: ReleaseStatus = "planned"
    owner: str = Field(min_length=2, max_length=80)
    notes: str = Field(default="", max_length=280)


class ReleaseUpdate(ReleaseCreate):
    pass


class ReleaseRead(ReleaseCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime


class ReleaseStats(BaseModel):
    total: int
    healthy: int
    deploying: int
    failed: int
