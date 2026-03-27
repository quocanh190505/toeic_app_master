from pydantic import BaseModel
from typing import Optional

class TopicBase(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None

class TopicCreate(TopicBase):
    pass  # Payload dùng để tạo mới

class Topic(TopicBase):
    id: int

    class Config:
        from_attributes = True # Cho phép Pydantic đọc data từ SQLAlchemy object