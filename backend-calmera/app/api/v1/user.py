from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from fastapi import Request
from jose import jwt, JWTError

from app.core.config import get_settings
from app.core.security import create_access_token, create_refresh_token
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.user import Token, UserCreate, UserLogin, UserResponse, UserDeleteResponse
from app.services.user import UserService
from app.db.session import get_db

router = APIRouter()
settings = get_settings()
SECRET_KEY = settings.SECRET_KEY
REFRESH_SECRET_KEY = settings.REFRESH_SECRET_KEY
ALGORITHM = settings.ALGORITHM

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register_user(user_create: UserCreate, db: Session = Depends(get_db)):
    user = UserService.create_user(db=db, user_data=user_create)
    return user


@router.post("/login", response_model=Token)
def login_user(user_login: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = UserService.authenticate_user(db=db, username=user_login.username, password=user_login.password)
    access_token = create_access_token(data={"sub": str(user.id)})
    refresh_token = create_refresh_token(data={"sub": str(user.id)})
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}


@router.delete("/me", response_model=UserDeleteResponse)
def delete_user(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    
    UserService.delete_user_and_data(db=db, user_id=current_user.id)
    
    return UserDeleteResponse(message="Пользователь и все связанные данные удалены успешно.")


@router.post("/refresh", response_model=Token)
def refresh_token(request: Request, db: Session = Depends(get_db)):
    refresh_token = request.headers.get("Authorization")
    if not refresh_token:
        raise HTTPException(status_code=401, detail="Отсутствует refresh токен")

    try:
        scheme, token = refresh_token.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Неверная схема авторизации")
        payload = jwt.decode(token, REFRESH_SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Неверный payload токена")
    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Невалидный refresh токен")

    user = db.query(User).get(int(user_id))
    if user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")

    new_access_token = create_access_token(data={"sub": str(user.id)})
    new_refresh_token = create_refresh_token(data={"sub": str(user.id)})

    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer"
    }


