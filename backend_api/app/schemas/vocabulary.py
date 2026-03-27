from pydantic import BaseModel
from typing import Optional


class VocabularyCreate(BaseModel):
    word: str
    meaning: str
    example: Optional[str] = None