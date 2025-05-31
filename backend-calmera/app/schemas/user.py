from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    username: str
    password: str


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str

    class Config:
        from_attributes = True

class UserDeleteResponse(BaseModel):
    message: str = Field(..., example="Пользователь и все связанные данные успешно удалены.")

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str