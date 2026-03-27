from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str = Field(..., min_length=6)
    target_score: int = 750


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    role: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str = Field(..., min_length=6)