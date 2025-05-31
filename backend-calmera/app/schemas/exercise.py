from typing import List, Optional
from pydantic import BaseModel, Field
from enum import Enum
from datetime import datetime

from app.models.exercise import ExerciseType, MediaType


class ExerciseBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=200, description="Название упражнения")
    description: str = Field(..., min_length=10, description="Описание упражнения")
    instructions: str = Field(..., min_length=10, description="Инструкции по выполнению")
    type: ExerciseType = Field(..., description="Тип упражнения")
    media_type: MediaType = Field(..., description="Тип медиа-контента")
    media_url: Optional[str] = Field(None, description="URL к медиа файлу")

class ExerciseUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=3, max_length=200)
    description: Optional[str] = Field(None, min_length=10)
    instructions: Optional[str] = Field(None, min_length=10)
    type: Optional[ExerciseType] = None
    media_type: Optional[MediaType] = None
    media_url: Optional[str] = None


class Exercise(ExerciseBase):
    id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class ExerciseCreate(ExerciseBase):
    pass

class ExerciseListResponse(BaseModel):
    exercises: List[Exercise]
    total: int
    page: int
    page_size: int
    total_pages: int

class ExerciseResponse(BaseModel):
    exercise: Exercise