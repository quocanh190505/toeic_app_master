from pydantic import BaseModel


class ProgressResponse(BaseModel):
    user_id: int
    studied_words: int
    completed_tests: int
    current_streak: int
    overall_progress: float


class SaveProgressRequest(BaseModel):
    user_id: int
    studied_words: int
    completed_tests: int
    current_streak: int
    overall_progress: float