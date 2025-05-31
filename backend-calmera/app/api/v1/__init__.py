from app.api.v1.exercises import router as exercises_router
from app.api.v1.chatbot import router as chatbot_router
from app.api.v1.diary import router as diary_router
from app.api.v1.user import router as user_router

__all__ = [
    "exercises_router", 
    "chatbot_router",
    "diary_router",
    "user_router"
]
