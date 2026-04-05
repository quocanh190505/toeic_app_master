from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.entities import User, VocabularyWord, UserStudiedWord, UserProgress, Topic

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

@router.get("")
def list_words(
    topic_id: int | None = Query(default=None), 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(VocabularyWord)
    
    if topic_id is not None:
        query = query.filter(VocabularyWord.topic_id == topic_id)
        
    words = query.order_by(VocabularyWord.id.desc()).all()

    # Lấy danh sách ID các từ mà User này đã học
    studied_records = db.query(UserStudiedWord.word_id).filter(
        UserStudiedWord.user_id == current_user.id
    ).all()
    studied_word_ids = {record[0] for record in studied_records}

    return [
        {
            "id": w.id,
            "word": w.word,
            "meaning": w.meaning,
            "example": w.example,
            "topic_id": w.topic_id,
            "is_studied": w.id in studied_word_ids # Trả về True/False để hiện tick xanh
        }
        for w in words
    ]
@router.get("/topics")
def list_topics(db: Session = Depends(get_db)):
    topics = db.query(Topic).all()
    # Trả về danh sách các chủ đề để Flutter vẽ lên màn hình
    return [
        {
            "id": t.id,
            "name": t.name,
            "description": t.description,
            "image_url": t.image_url
        }
        for t in topics
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


@router.delete("/{word_id}/study")
def unmark_word_studied(
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

    if not existing:
        return {"message": "Word is not marked as studied"}

    db.delete(existing)

    progress = ensure_progress(db, current_user.id)
    if progress.studied_words > 0:
        progress.studied_words -= 1

    db.commit()

    return {"message": "Word unmarked as studied"}

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
            "topic_id": word.topic_id
        }
        for row, word in rows
    ]
