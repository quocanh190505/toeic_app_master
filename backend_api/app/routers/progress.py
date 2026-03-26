from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.entities import UserProgress
from app.schemas.progress import ProgressResponse, SaveProgressRequest

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/{user_id}", response_model=ProgressResponse)
def get_progress(user_id: int, db: Session = Depends(get_db)):
    progress = db.query(UserProgress).filter(UserProgress.user_id == user_id).first()

    if not progress:
        progress = UserProgress(
            user_id=user_id,
            studied_words=0,
            completed_tests=0,
            current_streak=0,
            overall_progress=0.0,
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
    )


@router.post("/save", response_model=ProgressResponse)
def save_progress(payload: SaveProgressRequest, db: Session = Depends(get_db)):
    progress = db.query(UserProgress).filter(UserProgress.user_id == payload.user_id).first()

    if not progress:
        progress = UserProgress(user_id=payload.user_id)
        db.add(progress)

    progress.studied_words = payload.studied_words
    progress.completed_tests = payload.completed_tests
    progress.current_streak = payload.current_streak
    progress.overall_progress = payload.overall_progress

    db.commit()
    db.refresh(progress)

    return ProgressResponse(
        user_id=progress.user_id,
        studied_words=progress.studied_words,
        completed_tests=progress.completed_tests,
        current_streak=progress.current_streak,
        overall_progress=float(progress.overall_progress),
    )