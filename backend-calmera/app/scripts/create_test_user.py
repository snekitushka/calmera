import sys
import os
from sqlalchemy.orm import Session
from passlib.context import CryptContext

sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from app.db.session import get_db
from app.models.user import User

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_test_user():
    db = next(get_db())
    
    existing_user = db.query(User).filter(User.username == "test_user").first()
    
    if existing_user:
        print("Тестовый пользователь уже существует с id:", existing_user.id)
        return existing_user
    
    test_user = User(
        username="test_user",
        email="test@example.com",
        phone="+12345678900",
        hashed_password=pwd_context.hash("test_password"),
        is_active=True,
        is_verified=True
    )
    
    db.add(test_user)
    db.commit()
    db.refresh(test_user)
    
    print(f"Тестовый пользователь создан с id: {test_user.id}")
    return test_user

if __name__ == "__main__":
    create_test_user() 