from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.openapi.utils import get_openapi
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.db.session import get_db
from app.models import base, chat, exercise, user
from app.api.v1 import exercises_router, chatbot_router, diary_router, user_router

settings = get_settings()


app = FastAPI(
    title="CalmEra Backend API",
    description="Backend API for mental health support application",
    version="1.0.0",
    docs_url=None,
    redoc_url=None,
)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/docs", include_in_schema=False)
async def custom_swagger_ui_html():
    return get_swagger_ui_html(
        openapi_url="/openapi.json",
        title="CalmErs API Documentation",
        swagger_js_url="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui-bundle.js",
        swagger_css_url="https://cdn.jsdelivr.net/npm/swagger-ui-dist@5/swagger-ui.css",
    )

@app.get("/openapi.json", include_in_schema=False)
async def get_open_api_endpoint():
    return get_openapi(
        title="CalmEra Backend API",
        version="1.0.0",
        description="Backend API for mental health support application",
        routes=app.routes,
    )

@app.get("/health")
async def health_check(db: Session = Depends(get_db)):
    try:
        # Try to make a simple query
        db.execute("SELECT 1")
        return {
            "status": "healthy",
            "database": "connected",
            "version": settings.VERSION
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "database": str(e),
            "version": settings.VERSION
        }

# Include routers
app.include_router(exercises_router, prefix=f"{settings.API_V1_STR}/exercises", tags=["Exercises"])
app.include_router(chatbot_router, prefix=f"{settings.API_V1_STR}/chatbot", tags=["Chatbot"])
app.include_router(diary_router, prefix=f"{settings.API_V1_STR}/diary", tags=["Diary"]) 
app.include_router(user_router, prefix=f"{settings.API_V1_STR}/user", tags=["User"]) 