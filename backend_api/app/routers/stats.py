from collections import defaultdict

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.entities import (
    User,
    UserProgress,
    TestAttempt,
    TestAttemptAnswer,
    UserBookmark,
    UserStudiedWord,
)

router = APIRouter(prefix="/stats", tags=["stats"])


@router.get("/dashboard/me")
def my_dashboard(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    progress = db.query(UserProgress).filter(UserProgress.user_id == current_user.id).first()
    attempts_count = db.query(TestAttempt).filter(TestAttempt.user_id == current_user.id).count()
    bookmarks_count = db.query(UserBookmark).filter(UserBookmark.user_id == current_user.id).count()
    studied_words_count = db.query(UserStudiedWord).filter(UserStudiedWord.user_id == current_user.id).count()

    latest_attempt = (
        db.query(TestAttempt)
        .filter(TestAttempt.user_id == current_user.id)
        .order_by(TestAttempt.submitted_at.desc())
        .first()
    )

    return {
        "user": {
            "id": current_user.id,
            "full_name": current_user.full_name,
            "email": current_user.email,
            "target_score": current_user.target_score,
        },
        "progress": {
            "studied_words": progress.studied_words if progress else 0,
            "completed_tests": progress.completed_tests if progress else 0,
            "current_streak": progress.current_streak if progress else 0,
            "overall_progress": float(progress.overall_progress) if progress else 0.0,
            "highest_score": progress.highest_score if progress else 0,
            "average_score": float(progress.average_score) if progress else 0.0,
        },
        "summary": {
            "attempts_count": attempts_count,
            "bookmarks_count": bookmarks_count,
            "studied_words_count": studied_words_count,
        },
        "latest_attempt": None if not latest_attempt else {
            "id": latest_attempt.id,
            "test_type": latest_attempt.test_type,
            "score": latest_attempt.score,
            "correct_count": latest_attempt.correct_count,
            "total_questions": latest_attempt.total_questions,
            "submitted_at": latest_attempt.submitted_at,
        },
    }


@router.get("/leaderboard")
def leaderboard(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(User, UserProgress)
        .join(UserProgress, UserProgress.user_id == User.id)
        .order_by(UserProgress.highest_score.desc(), UserProgress.average_score.desc())
        .limit(limit)
        .all()
    )

    return [
        {
            "user_id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "highest_score": progress.highest_score,
            "average_score": float(progress.average_score),
            "completed_tests": progress.completed_tests,
        }
        for user, progress in rows
    ]


@router.get("/parts/me")
def my_part_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(
            TestAttemptAnswer.part,
            func.count(TestAttemptAnswer.id).label("total"),
            func.sum(func.case((TestAttemptAnswer.is_correct == True, 1), else_=0)).label("correct"),
        )
        .join(TestAttempt, TestAttempt.id == TestAttemptAnswer.attempt_id)
        .filter(TestAttempt.user_id == current_user.id)
        .group_by(TestAttemptAnswer.part)
        .all()
    )

    stats = {part: {"total": 0, "correct": 0, "accuracy": 0.0} for part in range(1, 8)}

    for part, total, correct in rows:
        correct = int(correct or 0)
        stats[part] = {
            "total": total,
            "correct": correct,
            "accuracy": round((correct / total) * 100, 2) if total > 0 else 0.0,
        }

    return stats