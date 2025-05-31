from typing import List, Optional
from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session
import math

from app.db.session import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.services.chatbot import ChatbotService
from app.schemas.chatbot import (
    MediaGenerationRequest,
    MediaGenerationResponse,
    MessageCreate,
    Message,
    ConversationResponse,
    ChatbotResponse
)

router = APIRouter()
chatbot_service = ChatbotService()

@router.get("/conversation", response_model=ConversationResponse)
def get_conversation_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100)
):
    """
    Получить историю сообщений пользователя
    """
    messages, total = chatbot_service.get_conversation_history(
        db=db,
        user_id=current_user.id,
        skip=skip
    )

    total_pages = math.ceil(total / limit) if total > 0 else 0
    page = skip // limit + 1 if skip % limit == 0 else skip // limit + 1

    return ConversationResponse(
        messages=messages,
        total=total,
        page=page,
        page_size=limit,
        total_pages=total_pages
    )


@router.post("/message", response_model=ChatbotResponse)
def send_message(
    message: MessageCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Отправить сообщение чат-боту и получить ответ
    """
    result = chatbot_service.process_user_message(
        db=db,
        user_id=current_user.id,
        message_data=message
    )

    return ChatbotResponse(
        message=result["message"],
    )

@router.post("/generate-media", response_model=MediaGenerationResponse)
async def generate_media(request: MediaGenerationRequest):
    media = await chatbot_service.generate_media(
        request.text,
        face_url=request.face_url,
        voice_name=request.voice_name)
    
    public_url = media.get("public_url")

    if not public_url:
        return JSONResponse(content={"error": "Не удалось получить ссылку"}, status_code=500)

    video_url = await chatbot_service.resolve_download_url(public_url)
    return {"video_url": video_url}
    
    # return MediaGenerationResponse(**media)
