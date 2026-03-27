from pydantic import BaseModel
from typing import Optional

class VocabularyCreate(BaseModel):
    word: str
    meaning: str
    example: Optional[str] = None
    topic_id: Optional[int] = None

class VocabularyUpdatePayload(BaseModel):
    word: Optional[str] = None
    meaning: Optional[str] = None
    example: Optional[str] = None
    topic_id: Optional[int] = None