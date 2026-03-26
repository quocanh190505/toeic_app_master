from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.entities import Question

router = APIRouter(prefix="/questions", tags=["questions"])


@router.get("")
def list_questions(part: int | None = None, db: Session = Depends(get_db)):
    query = db.query(Question)

    if part is not None:
        query = query.filter(Question.part == part)

    results = query.limit(50).all()

    return [
        {
            "id": q.id,
            "part": q.part,
            "content": q.content,
            "options": [q.option_a, q.option_b, q.option_c, q.option_d],
            "correct_answer": q.correct_answer,
            "audio_url": q.audio_url,
            "explanation": q.explanation,
        }
        for q in results
    ]