from sqlalchemy import Column, Integer, ForeignKey, DateTime, Enum, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .base import Base
import enum

class EmotionalState(enum.Enum):
    GREAT = "Отлично"
    GOOD = "Хорошо"
    OKAY = "Нормально"
    SAD = "Грустно"
    AWFUL = "Ужасно"

class DiaryEntry(Base):
    # Внешний ключ
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)
    
    # Основная информация
    event_datetime = Column(DateTime, default=datetime.utcnow, nullable=False) # Время события
    emotional_state = Column(Enum(EmotionalState), nullable=False) # Эмоция
    situation = Column(Text, nullable=True)  # Описание ситуации
    mood = Column(Text, nullable=True)  # Описание чувств
    thoughts = Column(Text, nullable=True)  # Мысли
    body_sensations = Column(Text, nullable=True)  # Телесные ощущения  
    
    # Связь с таблицей User
    user = relationship("User", back_populates="diary_entries") 

    