from pydantic import BaseModel


class ProgressResponse(BaseModel):
    user_id: int
    studied_words: int
    completed_tests: int
    current_streak: int
    overall_progress: float
    total_questions_answered: int
    total_correct_answers: int
    highest_score: int
    average_score: float