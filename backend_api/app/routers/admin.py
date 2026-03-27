import os
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Query, Form, File, UploadFile
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import require_admin
from app.models.entities import Question, User, TestAttempt
from app.services.auth_service import hash_password

router = APIRouter(prefix="/admin", tags=["admin"])

BASE_UPLOAD_DIR = Path("uploads")
AUDIO_UPLOAD_DIR = BASE_UPLOAD_DIR / "audio"
IMAGE_UPLOAD_DIR = BASE_UPLOAD_DIR / "images"

AUDIO_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
IMAGE_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


def save_upload_file(
    file: UploadFile,
    folder: Path,
    allowed_content_types: list[str],
) -> str:
    if file.content_type not in allowed_content_types:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type: {file.content_type}",
        )

    ext = os.path.splitext(file.filename or "")[1].lower()
    filename = f"{uuid.uuid4().hex}{ext}"
    filepath = folder / filename

    with open(filepath, "wb") as f:
        f.write(file.file.read())

    return str(filepath).replace("\\", "/")


def delete_file_if_exists(filepath: str | None) -> None:
    if not filepath:
        return

    path = Path(filepath.lstrip("/"))
    if path.exists() and path.is_file():
        path.unlink()


@router.get("/users")
def list_users(
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    users = db.query(User).all()
    return [
        {
            "id": u.id,
            "full_name": u.full_name,
            "email": u.email,
            "role": u.role,
            "target_score": u.target_score,
        }
        for u in users
    ]


@router.get("/questions")
def list_questions_admin(
    part: int | None = None,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    query = db.query(Question)

    if part is not None:
        query = query.filter(Question.part == part)

    results = query.limit(300).all()

    return [
        {
            "id": q.id,
            "part": q.part,
            "content": q.content,
            "option_a": q.option_a,
            "option_b": q.option_b,
            "option_c": q.option_c,
            "option_d": q.option_d,
            "correct_answer": q.correct_answer,
            "audio_url": q.audio_url,
            "image_url": q.image_url,
            "explanation": q.explanation,
        }
        for q in results
    ]


@router.post("/questions")
def create_question_admin(
    part: int = Form(...),
    content: str = Form(...),
    option_a: str = Form(...),
    option_b: str = Form(...),
    option_c: str = Form(...),
    option_d: str = Form(...),
    correct_answer: str = Form(...),
    explanation: str | None = Form(default=None),
    audio: UploadFile | None = File(default=None),
    image: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    if correct_answer not in ["A", "B", "C", "D"]:
        raise HTTPException(status_code=400, detail="correct_answer must be A, B, C, or D")

    audio_url = None
    image_url = None

    if audio is not None:
        saved_audio_path = save_upload_file(
            audio,
            AUDIO_UPLOAD_DIR,
            [
                "audio/mpeg",
                "audio/mp3",
                "audio/wav",
                "audio/x-wav",
                "audio/aac",
                "audio/ogg",
                "audio/mp4",
            ],
        )
        audio_url = f"/{saved_audio_path}"

    if image is not None:
        saved_image_path = save_upload_file(
            image,
            IMAGE_UPLOAD_DIR,
            [
                "image/jpeg",
                "image/jpg",
                "image/png",
                "image/webp",
            ],
        )
        image_url = f"/{saved_image_path}"

    question = Question(
        part=part,
        content=content,
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        option_d=option_d,
        correct_answer=correct_answer,
        audio_url=audio_url,
        image_url=image_url,
        explanation=explanation,
    )

    db.add(question)
    db.commit()
    db.refresh(question)

    return {
        "message": "Question created successfully",
        "id": question.id,
        "part": question.part,
        "content": question.content,
        "option_a": question.option_a,
        "option_b": question.option_b,
        "option_c": question.option_c,
        "option_d": question.option_d,
        "correct_answer": question.correct_answer,
        "audio_url": question.audio_url,
        "image_url": question.image_url,
        "explanation": question.explanation,
    }


@router.put("/questions/{question_id}")
def update_question_admin(
    question_id: int,
    part: int = Form(...),
    content: str = Form(...),
    option_a: str = Form(...),
    option_b: str = Form(...),
    option_c: str = Form(...),
    option_d: str = Form(...),
    correct_answer: str = Form(...),
    explanation: str | None = Form(default=None),
    audio: UploadFile | None = File(default=None),
    image: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    if correct_answer not in ["A", "B", "C", "D"]:
        raise HTTPException(status_code=400, detail="correct_answer must be A, B, C, or D")

    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    question.part = part
    question.content = content
    question.option_a = option_a
    question.option_b = option_b
    question.option_c = option_c
    question.option_d = option_d
    question.correct_answer = correct_answer
    question.explanation = explanation

    if audio is not None:
        delete_file_if_exists(question.audio_url)
        saved_audio_path = save_upload_file(
            audio,
            AUDIO_UPLOAD_DIR,
            [
                "audio/mpeg",
                "audio/mp3",
                "audio/wav",
                "audio/x-wav",
                "audio/aac",
                "audio/ogg",
                "audio/mp4",
            ],
        )
        question.audio_url = f"/{saved_audio_path}"

    if image is not None:
        delete_file_if_exists(question.image_url)
        saved_image_path = save_upload_file(
            image,
            IMAGE_UPLOAD_DIR,
            [
                "image/jpeg",
                "image/jpg",
                "image/png",
                "image/webp",
            ],
        )
        question.image_url = f"/{saved_image_path}"

    db.commit()
    db.refresh(question)

    return {
        "message": "Question updated successfully",
        "id": question.id,
        "part": question.part,
        "content": question.content,
        "option_a": question.option_a,
        "option_b": question.option_b,
        "option_c": question.option_c,
        "option_d": question.option_d,
        "correct_answer": question.correct_answer,
        "audio_url": question.audio_url,
        "image_url": question.image_url,
        "explanation": question.explanation,
    }


@router.delete("/questions/{question_id}")
def delete_question_admin(
    question_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")

    delete_file_if_exists(question.audio_url)
    delete_file_if_exists(question.image_url)

    db.delete(question)
    db.commit()

    return {"message": "Question deleted successfully"}


@router.get("/attempts")
def list_attempts_admin(
    user_id: int | None = Query(default=None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    query = db.query(TestAttempt)

    if user_id is not None:
        query = query.filter(TestAttempt.user_id == user_id)

    attempts = query.order_by(TestAttempt.submitted_at.desc()).all()

    return [
        {
            "attempt_id": a.id,
            "user_id": a.user_id,
            "test_type": a.test_type,
            "total_questions": a.total_questions,
            "correct_count": a.correct_count,
            "score": a.score,
            "submitted_at": a.submitted_at,
        }
        for a in attempts
    ]


@router.put("/users/{user_id}/role")
def update_user_role(
    user_id: int,
    role: str = Query(...),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    if role not in ["admin", "user"]:
        raise HTTPException(status_code=400, detail="Invalid role")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.role = role
    db.commit()
    db.refresh(user)

    return {
        "message": "User role updated successfully",
        "user_id": user.id,
        "email": user.email,
        "role": user.role,
    }


@router.post("/users/{user_id}/reset-password")
def admin_reset_user_password(
    user_id: int,
    new_password: str = Query(..., min_length=6),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password_hash = hash_password(new_password)
    db.commit()

    return {"message": "Password reset successfully"}