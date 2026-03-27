from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, require_admin
from app.models.entities import User, VocabularyWord, UserStudiedWord, UserProgress
from app.schemas.vocabulary import VocabularyCreate

router = APIRouter(prefix="/vocabulary", tags=["vocabulary"])


def ensure_progress(db: Session, user_id: int):
    progress = db.query(UserProgress).filter(UserProgress.user_id == user_id).first()
    if not progress:
        progress = UserProgress(
            user_id=user_id,
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
        db.flush()
    return progress


@router.post("")
def create_word(
    payload: VocabularyCreate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    existing = db.query(VocabularyWord).filter(VocabularyWord.word == payload.word).first()
    if existing:
        raise HTTPException(status_code=400, detail="Word already exists")

    word = VocabularyWord(
        word=payload.word,
        meaning=payload.meaning,
        example=payload.example,
    )
    db.add(word)
    db.commit()
    db.refresh(word)

    return {"message": "Word created successfully", "id": word.id}


@router.get("")
def list_words(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    words = db.query(VocabularyWord).order_by(VocabularyWord.id.desc()).all()
    return [
        {
            "id": w.id,
            "word": w.word,
            "meaning": w.meaning,
            "example": w.example,
        }
        for w in words
    ]


@router.post("/{word_id}/study")
def mark_word_studied(
    word_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    word = db.query(VocabularyWord).filter(VocabularyWord.id == word_id).first()
    if not word:
        raise HTTPException(status_code=404, detail="Word not found")

    existing = db.query(UserStudiedWord).filter(
        UserStudiedWord.user_id == current_user.id,
        UserStudiedWord.word_id == word_id,
    ).first()

    if existing:
        return {"message": "Word already marked as studied"}

    db.add(UserStudiedWord(user_id=current_user.id, word_id=word_id))

    progress = ensure_progress(db, current_user.id)
    progress.studied_words += 1

    db.commit()

    return {"message": "Word marked as studied"}


@router.get("/studied/me")
def my_studied_words(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(UserStudiedWord, VocabularyWord)
        .join(VocabularyWord, VocabularyWord.id == UserStudiedWord.word_id)
        .filter(UserStudiedWord.user_id == current_user.id)
        .all()
    )

    return [
        {
            "id": row.id,
            "studied_at": row.studied_at,
            "word": word.word,
            "meaning": word.meaning,
            "example": word.example,
        }
        for row, word in rows
    ]