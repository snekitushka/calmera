from sqlalchemy import Column, String, Text, Enum
from sqlalchemy.orm import relationship
import enum
from .base import Base

class ExerciseType(enum.Enum):
    CBT = "cbt"  # Когнитивно-поведенческая терапия
    BREATHING = "breathing"  # Дыхательные упражнения
    RELAXATION = "relaxation"  # Техники релаксации
    MEDITATION = "meditation"  # Медитация

class MediaType(enum.Enum):
    TEXT = "text"
    AUDIO = "audio"
    VIDEO = "video"


class Exercise(Base):
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    instructions = Column(Text, nullable=False)
    type = Column(Enum(ExerciseType), nullable=False)
    media_type = Column(Enum(MediaType), nullable=False)
    media_url = Column(String(500), nullable=True)
