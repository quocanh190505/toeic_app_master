import os
import uuid
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, Query, Form, File, UploadFile
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import require_admin
# Đã bổ sung import đầy đủ
from app.models.entities import (
    Question,
    RefreshToken,
    TestAttempt,
    TestAttemptAnswer,
    Topic,
    User,
    UserBookmark,
    UserProgress,
    UserStudiedWord,
    VocabularyWord,
)
from app.services.auth_service import hash_password
from app.schemas.vocabulary import VocabularyCreate, VocabularyUpdatePayload

router = APIRouter(prefix="/admin", tags=["admin"])

BASE_UPLOAD_DIR = Path("uploads")
AUDIO_UPLOAD_DIR = BASE_UPLOAD_DIR / "audio"
IMAGE_UPLOAD_DIR = BASE_UPLOAD_DIR / "images"

AUDIO_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
IMAGE_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


def infer_section_from_part(part: int) -> str:
    return "listening" if part <= 4 else "reading"


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


def delete_question_media_if_unused(
    db: Session,
    *,
    direct_audio_url: str | None = None,
    direct_image_url: str | None = None,
    shared_audio_url: str | None = None,
    shared_image_url: str | None = None,
    exclude_question_id: int | None = None,
) -> None:
    filters = []
    if exclude_question_id is not None:
        filters.append(Question.id != exclude_question_id)

    candidates = [
        (direct_audio_url, Question.audio_url),
        (direct_image_url, Question.image_url),
        (shared_audio_url, Question.shared_audio_url),
        (shared_image_url, Question.shared_image_url),
    ]

    for filepath, column in candidates:
        if not filepath:
            continue

        query = db.query(Question).filter(column == filepath)
        for condition in filters:
            query = query.filter(condition)

        if query.first() is None:
            delete_file_if_exists(filepath)


def revoke_user_refresh_tokens(db: Session, user_id: int) -> None:
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.is_revoked == False,
    ).update(
        {"is_revoked": True},
        synchronize_session=False,
    )


def get_topic_or_404(db: Session, topic_id: int) -> Topic:
    topic = db.query(Topic).filter(Topic.id == topic_id).first()
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")
    return topic


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
            "section": q.section or infer_section_from_part(q.part),
            "group_key": q.group_key,
            "question_order": q.question_order,
            "instructions": q.instructions,
            "shared_content": q.shared_content,
            "shared_audio_url": q.shared_audio_url,
            "shared_image_url": q.shared_image_url,
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
    section: str | None = Form(default=None),
    group_key: str | None = Form(default=None),
    question_order: int = Form(default=1),
    instructions: str | None = Form(default=None),
    shared_content: str | None = Form(default=None),
    content: str = Form(...),
    option_a: str = Form(...),
    option_b: str = Form(...),
    option_c: str = Form(...),
    option_d: str = Form(...),
    correct_answer: str = Form(...),
    explanation: str | None = Form(default=None),
    shared_image_url: str | None = Form(default=None),
    image_url: str | None = Form(default=None),
    shared_audio: UploadFile | None = File(default=None),
    shared_image: UploadFile | None = File(default=None),
    audio: UploadFile | None = File(default=None),
    image: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    if correct_answer not in ["A", "B", "C", "D"]:
        raise HTTPException(status_code=400, detail="correct_answer must be A, B, C, or D")

    resolved_section = (section or infer_section_from_part(part)).strip().lower()
    if resolved_section not in ["listening", "reading"]:
        raise HTTPException(status_code=400, detail="section must be listening or reading")
    if question_order < 1:
        raise HTTPException(status_code=400, detail="question_order must be at least 1")

    audio_url = None
    direct_image_url = (image_url or "").strip() or None
    shared_audio_url = None
    direct_shared_image_url = (shared_image_url or "").strip() or None

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

    if shared_audio is not None:
        saved_shared_audio_path = save_upload_file(
            shared_audio,
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
        shared_audio_url = f"/{saved_shared_audio_path}"

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
        direct_image_url = f"/{saved_image_path}"

    if shared_image is not None:
        saved_shared_image_path = save_upload_file(
            shared_image,
            IMAGE_UPLOAD_DIR,
            [
                "image/jpeg",
                "image/jpg",
                "image/png",
                "image/webp",
            ],
        )
        direct_shared_image_url = f"/{saved_shared_image_path}"

    question = Question(
        part=part,
        section=resolved_section,
        group_key=(group_key or "").strip() or None,
        question_order=question_order,
        instructions=(instructions or "").strip() or None,
        shared_content=(shared_content or "").strip() or None,
        shared_audio_url=shared_audio_url,
        shared_image_url=direct_shared_image_url,
        content=content,
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        option_d=option_d,
        correct_answer=correct_answer,
        audio_url=audio_url,
        image_url=direct_image_url,
        explanation=explanation,
    )

    db.add(question)
    db.commit()
    db.refresh(question)

    return {
        "message": "Question created successfully",
        "id": question.id,
        "part": question.part,
        "section": question.section,
        "group_key": question.group_key,
        "question_order": question.question_order,
        "instructions": question.instructions,
        "shared_content": question.shared_content,
        "shared_audio_url": question.shared_audio_url,
        "shared_image_url": question.shared_image_url,
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
    section: str | None = Form(default=None),
    group_key: str | None = Form(default=None),
    question_order: int = Form(default=1),
    instructions: str | None = Form(default=None),
    shared_content: str | None = Form(default=None),
    content: str = Form(...),
    option_a: str = Form(...),
    option_b: str = Form(...),
    option_c: str = Form(...),
    option_d: str = Form(...),
    correct_answer: str = Form(...),
    explanation: str | None = Form(default=None),
    shared_image_url: str | None = Form(default=None),
    image_url: str | None = Form(default=None),
    shared_audio: UploadFile | None = File(default=None),
    shared_image: UploadFile | None = File(default=None),
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

    resolved_section = (section or infer_section_from_part(part)).strip().lower()
    if resolved_section not in ["listening", "reading"]:
        raise HTTPException(status_code=400, detail="section must be listening or reading")
    if question_order < 1:
        raise HTTPException(status_code=400, detail="question_order must be at least 1")

    old_audio_url = question.audio_url
    old_image_url = question.image_url
    old_shared_audio_url = question.shared_audio_url
    old_shared_image_url = question.shared_image_url

    question.part = part
    question.section = resolved_section
    question.group_key = (group_key or "").strip() or None
    question.question_order = question_order
    question.instructions = (instructions or "").strip() or None
    question.shared_content = (shared_content or "").strip() or None
    question.content = content
    question.option_a = option_a
    question.option_b = option_b
    question.option_c = option_c
    question.option_d = option_d
    question.correct_answer = correct_answer
    question.explanation = explanation
    direct_image_url = (image_url or "").strip()
    direct_shared_image_url = (shared_image_url or "").strip()

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
        question.audio_url = f"/{saved_audio_path}"

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
        question.image_url = f"/{saved_image_path}"
    elif direct_image_url:
        question.image_url = direct_image_url

    if shared_audio is not None:
        saved_shared_audio_path = save_upload_file(
            shared_audio,
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
        question.shared_audio_url = f"/{saved_shared_audio_path}"

    if shared_image is not None:
        saved_shared_image_path = save_upload_file(
            shared_image,
            IMAGE_UPLOAD_DIR,
            [
                "image/jpeg",
                "image/jpg",
                "image/png",
                "image/webp",
            ],
        )
        question.shared_image_url = f"/{saved_shared_image_path}"
    elif direct_shared_image_url:
        question.shared_image_url = direct_shared_image_url

    db.commit()
    db.refresh(question)

    delete_question_media_if_unused(
        db,
        direct_audio_url=old_audio_url if old_audio_url != question.audio_url else None,
        direct_image_url=old_image_url if old_image_url != question.image_url else None,
        shared_audio_url=(
            old_shared_audio_url
            if old_shared_audio_url != question.shared_audio_url
            else None
        ),
        shared_image_url=(
            old_shared_image_url
            if old_shared_image_url != question.shared_image_url
            else None
        ),
        exclude_question_id=question.id,
    )

    return {
        "message": "Question updated successfully",
        "id": question.id,
        "part": question.part,
        "section": question.section,
        "group_key": question.group_key,
        "question_order": question.question_order,
        "instructions": question.instructions,
        "shared_content": question.shared_content,
        "shared_audio_url": question.shared_audio_url,
        "shared_image_url": question.shared_image_url,
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

    old_audio_url = question.audio_url
    old_image_url = question.image_url
    old_shared_audio_url = question.shared_audio_url
    old_shared_image_url = question.shared_image_url

    db.query(TestAttemptAnswer).filter(
        TestAttemptAnswer.question_id == question_id
    ).delete(synchronize_session=False)
    db.query(UserBookmark).filter(
        UserBookmark.question_id == question_id
    ).delete(synchronize_session=False)

    db.delete(question)
    db.commit()

    delete_question_media_if_unused(
        db,
        direct_audio_url=old_audio_url,
        direct_image_url=old_image_url,
        shared_audio_url=old_shared_audio_url,
        shared_image_url=old_shared_image_url,
        exclude_question_id=question_id,
    )

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
    revoke_user_refresh_tokens(db, user.id)
    db.commit()

    return {"message": "Password reset successfully"}


@router.delete("/users/{user_id}")
def delete_user_admin(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.id == admin.id:
        raise HTTPException(status_code=400, detail="You cannot delete your own admin account")

    attempts = db.query(TestAttempt).filter(TestAttempt.user_id == user_id).all()
    attempt_ids = [attempt.id for attempt in attempts]

    if attempt_ids:
        db.query(TestAttemptAnswer).filter(
            TestAttemptAnswer.attempt_id.in_(attempt_ids)
        ).delete(synchronize_session=False)

    db.query(TestAttempt).filter(TestAttempt.user_id == user_id).delete(synchronize_session=False)
    db.query(UserBookmark).filter(UserBookmark.user_id == user_id).delete(synchronize_session=False)
    db.query(UserStudiedWord).filter(UserStudiedWord.user_id == user_id).delete(synchronize_session=False)
    db.query(UserProgress).filter(UserProgress.user_id == user_id).delete(synchronize_session=False)
    db.query(RefreshToken).filter(RefreshToken.user_id == user_id).delete(synchronize_session=False)

    db.delete(user)
    db.commit()

    return {"message": "User deleted successfully", "user_id": user_id}


# =================================================================
# QUẢN LÝ CHỦ ĐỀ (TOPICS) DÀNH CHO ADMIN
# =================================================================

# =================================================================
# QUẢN LÝ CHỦ ĐỀ (TOPICS) DÀNH CHO ADMIN
# =================================================================

@router.post("/topics")
def create_topic_admin(
    name: str = Form(...),
    description: str | None = Form(default=None),
    image: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    image_url = None
    existing_topic = db.query(Topic).filter(Topic.name == name).first()
    if existing_topic:
        raise HTTPException(status_code=400, detail="Topic already exists")

    if image is not None:
        saved_image_path = save_upload_file(
            image,
            IMAGE_UPLOAD_DIR,
            ["image/jpeg", "image/jpg", "image/png", "image/webp"],
        )
        image_url = f"/{saved_image_path}"

    topic = Topic(
        name=name,
        description=description,
        image_url=image_url
    )
    db.add(topic)
    db.commit()
    db.refresh(topic)
    
    return {"message": "Topic created successfully", "id": topic.id}

@router.put("/topics/{topic_id}")
def update_topic_admin(
    topic_id: int,
    name: str = Form(...),
    description: str | None = Form(default=None),
    image: UploadFile | None = File(default=None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    topic = get_topic_or_404(db, topic_id)
    existing_topic = (
        db.query(Topic)
        .filter(Topic.name == name, Topic.id != topic_id)
        .first()
    )
    if existing_topic:
        raise HTTPException(status_code=400, detail="Topic already exists")
    
    topic.name = name
    topic.description = description
    
    if image is not None:
        delete_file_if_exists(topic.image_url)
        saved_image_path = save_upload_file(
            image,
            IMAGE_UPLOAD_DIR,
            ["image/jpeg", "image/jpg", "image/png", "image/webp"],
        )
        topic.image_url = f"/{saved_image_path}"

    db.commit()
    db.refresh(topic)
    return {"message": "Topic updated successfully"}

@router.delete("/topics/{topic_id}")
def delete_topic_admin(
    topic_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    topic = db.query(Topic).filter(Topic.id == topic_id).first()
    if not topic:
        raise HTTPException(status_code=404, detail="Topic not found")

    words_count = db.query(VocabularyWord).filter(
        VocabularyWord.topic_id == topic_id
    ).count()
    if words_count > 0:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete topic while it still contains vocabulary words",
        )
    
    delete_file_if_exists(topic.image_url)
    db.delete(topic)
    db.commit()
    return {"message": "Topic deleted successfully"}


# =================================================================
# QUẢN LÝ TỪ VỰNG (VOCABULARY) DÀNH CHO ADMIN
# =================================================================

@router.post("/vocabulary")
def create_word_admin(
    payload: VocabularyCreate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin), 
):
    existing = db.query(VocabularyWord).filter(VocabularyWord.word == payload.word).first()
    if existing:
        raise HTTPException(status_code=400, detail="Word already exists")

    if payload.topic_id is not None:
        get_topic_or_404(db, payload.topic_id)

    word = VocabularyWord(
        word=payload.word,
        meaning=payload.meaning,
        example=payload.example,
        topic_id=payload.topic_id 
    )
    db.add(word)
    db.commit()
    db.refresh(word)

    return {"message": "Word created successfully", "id": word.id}

@router.put("/vocabulary/{word_id}")
def update_word_admin(
    word_id: int,
    payload: VocabularyUpdatePayload,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    word_db = db.query(VocabularyWord).filter(VocabularyWord.id == word_id).first()
    if not word_db:
        raise HTTPException(status_code=404, detail="Word not found")

    if payload.word is not None:
        existing = db.query(VocabularyWord).filter(VocabularyWord.word == payload.word, VocabularyWord.id != word_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Word already exists")
        word_db.word = payload.word
        
    if payload.meaning is not None:
        word_db.meaning = payload.meaning
    if payload.example is not None:
        word_db.example = payload.example
    if payload.topic_id is not None:
        get_topic_or_404(db, payload.topic_id)
        word_db.topic_id = payload.topic_id

    db.commit()
    db.refresh(word_db)
    
    return {"message": "Word updated successfully", "id": word_db.id}

@router.delete("/vocabulary/{word_id}")
def delete_word_admin(
    word_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    word = db.query(VocabularyWord).filter(VocabularyWord.id == word_id).first()
    if not word:
        raise HTTPException(status_code=404, detail="Word not found")

    # Xóa lịch sử học từ này của mọi User trước để tránh lỗi ForeignKey
    db.query(UserStudiedWord).filter(UserStudiedWord.word_id == word_id).delete()
    
    db.delete(word)
    db.commit()

    return {"message": "Word deleted successfully"}
