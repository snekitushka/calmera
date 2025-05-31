from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
from enum import Enum

from app.models.chat import MessageType

class MessageBase(BaseModel):
    content: str = Field(..., min_length=1, description="Содержание сообщения")
    message_type: MessageType = Field(default=MessageType.USER, description="Тип сообщения")

class MessageCreate(MessageBase):
    pass

class Message(MessageBase):
    id: int
    user_id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class ConversationResponse(BaseModel):
    messages: List[Message]
    total: int
    page: int
    page_size: int
    total_pages: int

class ChatbotResponse(BaseModel):
    message: str

class MediaGenerationRequest(BaseModel):
    text: str
    voice_name: str = Field(..., alias="voice-name")
    face_url: str = Field(..., alias="face-url")

class MediaGenerationResponse(BaseModel):
    public_url: Optional[str]
    
    