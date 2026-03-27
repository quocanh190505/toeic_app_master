import os
import random
import shutil
import uuid
from collections import defaultdict

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, require_admin
from app.models.entities import (
    Question,
    User,
    UserProgress,
    TestAttempt,
    TestAttemptAnswer,
    UserBookmark,
)
from app.schemas.question import (
    QuestionCreate,
    QuestionUpdate,
    SubmitQuestionsRequest,
    AttemptSummaryResponse,
)

router = APIRouter(prefix="/questions", tags=["questions"])

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

FULL_TEST_DISTRIBUTION = {
    1: 6,
    2: 25,
    3: 39,
    4: 30,
    5: 30,
    6: 16,
    7: 54,
}

MINI_TEST_DISTRIBUTION = {
    1: 2,
    2: 5,
    3: 5,
    4: 5,
    5: 5,
    6: 4,
    7: 8,
}


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


def serialize_question_public(q: Question):
    return {
        "id": q.id,
        "part": q.part,
        "content": q.content,
        "options": {
            "A": q.option_a,
            "B": q.option_b,
            "C": q.option_c,
            "D": q.option_d,
        },
        "audio_url": q.audio_url,
        "image_url": q.image_url,
    }


def build_part_stats_response(part_stats):
    response = {}
    for part in sorted(part_stats.keys()):
        total = int(part_stats[part]["total"])
        correct = int(part_stats[part]["correct"])
        accuracy = round((correct / total) * 100, 2) if total > 0 else 0.0

        response[str(part)] = {
            "total": total,
            "correct": correct,
            "accuracy": accuracy,
        }
    return response


@router.get("")
def list_questions(
    part: int | None = Query(default=None),
    random_mode: bool = Query(default=False),
    limit: int = Query(default=50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(Question)

    if part is not None:
        query = query.filter(Question.part == part)

    questions = query.all()

    if random_mode:
        random.shuffle(questions)
        questions = questions[:limit]
    else:
        questions = questions[:limit]

    return [serialize_question_public(q) for q in questions]


@router.get("/mini-test")
def get_mini_test(
    part: int | None = Query(default=None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if part is not None:
        questions = db.query(Question).filter(Question.part == part).all()

        if len(questions) < 10:
            raise HTTPException(
                status_code=400,
                detail=f"Not enough questions for part {part}. Need at least 10 questions.",
            )

        selected = random.sample(questions, 10)

        return {
            "test_type": "mini",
            "part": part,
            "total_questions": len(selected),
            "questions": [serialize_question_public(q) for q in selected],
        }

    selected = []

    for p, count in MINI_TEST_DISTRIBUTION.items():
        part_questions = db.query(Question).filter(Question.part == p).all()

        if len(part_questions) < count:
            raise HTTPException(
                status_code=400,
                detail=f"Not enough questions for part {p}. Need at least {count} questions.",
            )

        selected.extend(random.sample(part_questions, count))

    random.shuffle(selected)

    return {
        "test_type": "mini",
        "part": None,
        "total_questions": len(selected),
        "questions": [serialize_question_public(q) for q in selected],
    }


@router.get("/full-test")
def get_full_test(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    selected = []

    for p, count in FULL_TEST_DISTRIBUTION.items():
        part_questions = db.query(Question).filter(Question.part == p).all()

        if len(part_questions) < count:
            raise HTTPException(
                status_code=400,
                detail=f"Not enough questions for part {p}. Need at least {count} questions.",
            )

        selected.extend(random.sample(part_questions, count))

    random.shuffle(selected)

    return {
        "test_type": "full",
        "total_questions": len(selected),
        "questions": [serialize_question_public(q) for q in selected],
    }


@router.post("/submit")
def submit_questions(
    payload: SubmitQuestionsRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not payload.answers:
        raise HTTPException(status_code=400, detail="Answers cannot be empty")

    question_ids = [item.question_id for item in payload.answers]

    if len(question_ids) != len(set(question_ids)):
        raise HTTPException(status_code=400, detail="Duplicate question_id in answers")

    questions = db.query(Question).filter(Question.id.in_(question_ids)).all()
    question_map = {q.id: q for q in questions}

    if len(question_map) != len(question_ids):
        raise HTTPException(status_code=400, detail="Some question_ids are invalid")

    total_questions = len(payload.answers)
    correct_count = 0
    part_stats = defaultdict(lambda: {"total": 0, "correct": 0})
    results = []

    attempt = TestAttempt(
        user_id=current_user.id,
        test_type=payload.test_type,
        total_questions=total_questions,
        correct_count=0,
        score=0,
    )
    db.add(attempt)
    db.flush()

    for item in payload.answers:
        q = question_map[item.question_id]
        is_correct = item.selected_answer == q.correct_answer

        if is_correct:
            correct_count += 1

        part_stats[q.part]["total"] += 1
        if is_correct:
            part_stats[q.part]["correct"] += 1

        db.add(
            TestAttemptAnswer(
                attempt_id=attempt.id,
                question_id=q.id,
                selected_answer=item.selected_answer,
                correct_answer=q.correct_answer,
                is_correct=is_correct,
                part=q.part,
            )
        )

        results.append(
            {
                "question_id": q.id,
                "part": q.part,
                "content": q.content,
                "options": {
                    "A": q.option_a,
                    "B": q.option_b,
                    "C": q.option_c,
                    "D": q.option_d,
                },
                "selected_answer": item.selected_answer,
                "correct_answer": q.correct_answer,
                "is_correct": is_correct,
                "explanation": q.explanation,
                "audio_url": q.audio_url,
                "image_url": q.image_url,
            }
        )

    score = correct_count
    attempt.correct_count = correct_count
    attempt.score = score

    progress = ensure_progress(db, current_user.id)

    old_completed = progress.completed_tests
    old_avg = float(progress.average_score)

    progress.completed_tests += 1
    progress.total_questions_answered += total_questions
    progress.total_correct_answers += correct_count
    progress.highest_score = max(progress.highest_score, score)
    progress.average_score = round(
        ((old_avg * old_completed) + score) / progress.completed_tests,
        2,
    )
    progress.overall_progress = round(
        (progress.total_correct_answers / progress.total_questions_answered) * 100,
        2,
    ) if progress.total_questions_answered > 0 else 0.0

    db.commit()
    db.refresh(attempt)
    db.refresh(progress)

    return {
        "attempt_id": attempt.id,
        "user_id": current_user.id,
        "user_email": current_user.email,
        "test_type": attempt.test_type,
        "total_questions": total_questions,
        "correct_count": correct_count,
        "score": score,
        "results": results,
        "part_stats": build_part_stats_response(part_stats),
        "progress": {
            "user_id": progress.user_id,
            "studied_words": progress.studied_words,
            "completed_tests": progress.completed_tests,
            "current_streak": progress.current_streak,
            "overall_progress": float(progress.overall_progress),
            "total_questions_answered": progress.total_questions_answered,
            "total_correct_answers": progress.total_correct_answers,
            "highest_score": progress.highest_score,
            "average_score": float(progress.average_score),
        },
    }


@router.get("/attempts", response_model=list[AttemptSummaryResponse])
def list_my_attempts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    attempts = (
        db.query(TestAttempt)
        .filter(TestAttempt.user_id == current_user.id)
        .order_by(TestAttempt.submitted_at.desc())
        .all()
    )

    return [
        AttemptSummaryResponse(
            id=a.id,
            test_type=a.test_type,
            total_questions=a.total_questions,
            correct_count=a.correct_count,
            score=a.score,
            submitted_at=a.submitted_at,
        )
        for a in attempts
    ]


@router.get("/attempts/{attempt_id}")
def get_attempt_detail(
    attempt_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    attempt = (
        db.query(TestAttempt)
        .filter(TestAttempt.id == attempt_id, TestAttempt.user_id == current_user.id)
        .first()
    )

    if not attempt:
        raise HTTPException(status_code=404, detail="Attempt not found")

    rows = (
        db.query(TestAttemptAnswer, Question)
        .join(Question, Question.id == TestAttemptAnswer.question_id)
        .filter(TestAttemptAnswer.attempt_id == attempt.id)
        .all()
    )

    results = []
    part_stats = defaultdict(lambda: {"total": 0, "correct": 0})

    for answer, question in rows:
        part_stats[question.part]["total"] += 1
        if answer.is_correct:
            part_stats[question.part]["correct"] += 1

        results.append(
            {
                "question_id": question.id,
                "part": question.part,
                "content": question.content,
                "options": {
                    "A": question.option_a,
                    "B": question.option_b,
                    "C": question.option_c,
                    "D": question.option_d,
                },
                "selected_answer": answer.selected_answer,
                "correct_answer": answer.correct_answer,
                "is_correct": answer.is_correct,
                "explanation": question.explanation,
                "audio_url": question.audio_url,
                "image_url": question.image_url,
            }
        )

    return {
        "attempt_id": attempt.id,
        "test_type": attempt.test_type,
        "total_questions": attempt.total_questions,
        "correct_count": attempt.correct_count,
        "score": attempt.score,
        "submitted_at": attempt.submitted_at,
        "part_stats": build_part_stats_response(part_stats),
        "results": results,
    }


@router.post("/{question_id}/bookmark")
def bookmark_question(
    question_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    question = db.query(Question).filter(Question.id == question_id).first()

    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    existing = db.query(UserBookmark).filter(
        UserBookmark.user_id == current_user.id,
        UserBookmark.question_id == question_id,
    ).first()

    if existing:
        return {"message": "Already bookmarked"}

    bookmark = UserBookmark(user_id=current_user.id, question_id=question_id)
    db.add(bookmark)
    db.commit()

    return {"message": "Bookmarked successfully"}


@router.delete("/{question_id}/bookmark")
def unbookmark_question(
    question_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    bookmark = db.query(UserBookmark).filter(
        UserBookmark.user_id == current_user.id,
        UserBookmark.question_id == question_id,
    ).first()

    if not bookmark:
        raise HTTPException(status_code=404, detail="Bookmark not found")

    db.delete(bookmark)
    db.commit()

    return {"message": "Bookmark removed successfully"}


@router.get("/bookmarks/me")
def list_my_bookmarks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(UserBookmark, Question)
        .join(Question, Question.id == UserBookmark.question_id)
        .filter(UserBookmark.user_id == current_user.id)
        .order_by(UserBookmark.created_at.desc())
        .all()
    )

    return [
        {
            "bookmark_id": b.id,
            "created_at": b.created_at,
            "question": serialize_question_public(q),
        }
        for b, q in rows
    ]


@router.post("")
def create_question(
    payload: QuestionCreate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    question = Question(
        part=payload.part,
        content=payload.content,
        option_a=payload.option_a,
        option_b=payload.option_b,
        option_c=payload.option_c,
        option_d=payload.option_d,
        correct_answer=payload.correct_answer,
        explanation=payload.explanation,
        audio_url=payload.audio_url,
        image_url=payload.image_url,
    )
    db.add(question)
    db.commit()
    db.refresh(question)

    return {
        "message": "Question created successfully",
        "id": question.id,
    }


@router.post("/upload")
def upload_question_media(
    file: UploadFile = File(...),
    admin: User = Depends(require_admin),
):
    ext = os.path.splitext(file.filename)[1].lower()
    allowed = [".mp3", ".wav", ".ogg", ".jpg", ".jpeg", ".png", ".webp"]

    if ext not in allowed:
        raise HTTPException(status_code=400, detail="Unsupported file type")

    filename = f"{uuid.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {
        "message": "Upload successful",
        "file_url": f"/uploads/{filename}",
    }


@router.put("/{question_id}")
def update_question(
    question_id: int,
    payload: QuestionUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    question = db.query(Question).filter(Question.id == question_id).first()

    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    update_data = payload.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(question, key, value)

    db.commit()
    db.refresh(question)

    return {
        "message": "Question updated successfully",
        "id": question.id,
    }


@router.delete("/{question_id}")
def delete_question(
    question_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    question = db.query(Question).filter(Question.id == question_id).first()

    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    db.delete(question)
    db.commit()

    return {"message": "Question deleted successfully"}