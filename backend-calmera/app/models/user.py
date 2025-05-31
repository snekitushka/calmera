from sqlalchemy import Column, String
from sqlalchemy.orm import relationship
from .base import Base

class User(Base):
    username = Column(String(50), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=True) 
    
    messages = relationship("ChatMessage", back_populates="user")
    diary_entries = relationship("DiaryEntry", back_populates="user") 