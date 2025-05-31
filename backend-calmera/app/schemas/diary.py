from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field, validator
from datetime import datetime

from app.models.diary import EmotionalState

class DiaryEntryBase(BaseModel):
    event_datetime: Optional[datetime] = Field(None, description="Дата и время события")
    emotional_state: EmotionalState = Field(..., description="Эмоциональное состояние")
    situation: Optional[str] = Field(None, description="Описание ситуации")
    mood: Optional[str] = Field(None, description="Описание чувств")
    thoughts: Optional[str] = Field(None, description="Мысли")
    body_sensations: Optional[str] = Field(None, description="Телесные ощущения")


class DiaryEntryCreate(DiaryEntryBase):
    pass


class DiaryEntryUpdate(BaseModel):
    event_datetime: Optional[datetime] = None
    emotional_state: Optional[EmotionalState] = None
    situation: Optional[str] = None
    mood: Optional[str] = None
    thoughts: Optional[str] = None
    body_sensations: Optional[str] = None

class DiaryEntry(DiaryEntryBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class DiaryEntryResponse(BaseModel):
    entry: DiaryEntry

class DiaryEntryListResponse(BaseModel):
    entries: List[DiaryEntry]
    total: int
    page: int
    page_size: int
    total_pages: int