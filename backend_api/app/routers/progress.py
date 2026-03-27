from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.entities import User, UserProgress
from app.schemas.progress import ProgressResponse

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/me", response_model=ProgressResponse)
def get_my_progress(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    progress = db.query(UserProgress).filter(UserProgress.user_id == current_user.id).first()

    if not progress:
        progress = UserProgress(
            user_id=current_user.id,
            studied_words=0,
            completed_tests=0,
            current_streak=0,
            overall_progress=0.0,
            total_questions_answered=0,
            total_correct_answers=0,
            highest_score=0,
            average_score=0.0,
        )
        db.add(progress)
        db.commit()
        db.refresh(progress)

    return ProgressResponse(
        user_id=progress.user_id,
        studied_words=progress.studied_words,
        completed_tests=progress.completed_tests,
        current_streak=progress.current_streak,
        overall_progress=float(progress.overall_progress),
        total_questions_answered=progress.total_questions_answered,
        total_correct_answers=progress.total_correct_answers,
        highest_score=progress.highest_score,
        average_score=float(progress.average_score),
    )