from sqlalchemy import Column, Integer, ForeignKey, Enum, Text
from sqlalchemy.orm import relationship
import enum
from .base import Base

class MessageType(enum.Enum):
    USER = "user"
    BOT = "bot"


class ChatMessage(Base):
    user_id = Column(Integer, ForeignKey("user.id"), nullable=False)

    message_type = Column(Enum(MessageType), nullable=False)
    content = Column(Text, nullable=False)
    
    user = relationship("User", back_populates="messages")

