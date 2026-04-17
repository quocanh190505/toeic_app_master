import io
import json
import os
import re
import uuid
import zipfile
import hashlib
import unicodedata
import xml.etree.ElementTree as ET
from pathlib import Path
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, Form, File, UploadFile
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import require_admin, require_staff, require_roles

from app.models.entities import (
    PremiumPaymentRequest,
    PublishedTest,
    PublishedTestItem,
    Question,
    QuestionGroup,
    QuestionWorkflow,
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
from app.routers.questions import (
    build_attempt_detail_response,
    get_published_test_questions,
    serialize_published_test_summary,
    serialize_question_public,
)
from app.services.auth_service import hash_password
from app.schemas.auth import PremiumPaymentReviewRequest
from app.schemas.vocabulary import VocabularyCreate, VocabularyUpdatePayload
from app.schemas.question import PublishedTestCreateRequest

router = APIRouter(prefix="/admin", tags=["admin"])

BASE_UPLOAD_DIR = Path("uploads")
AUDIO_UPLOAD_DIR = BASE_UPLOAD_DIR / "audio"
IMAGE_UPLOAD_DIR = BASE_UPLOAD_DIR / "images"

AUDIO_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
IMAGE_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

PREMIUM_MONTH_PRICES = {
    1: 79000,
    3: 199000,
    12: 599000,
}

DOCUMENT_FIELD_ALIASES = {
    "part": "part",
    "phan": "part",
    "section": "section",
    "phan_thi": "section",
    "difficulty": "difficulty",
    "do_kho": "difficulty",
    "muc_do": "difficulty",
    "group_key": "group_key",
    "ma_nhom": "group_key",
    "nhom": "group_key",
    "question_order": "question_order",
    "thu_tu": "question_order",
    "instructions": "instructions",
    "huong_dan": "instructions",
    "shared_content": "shared_content",
    "noi_dung_chung": "shared_content",
    "doan_van_chung": "shared_content",
    "shared_audio_url": "shared_audio_url",
    "audio_chung": "shared_audio_url",
    "shared_image_url": "shared_image_url",
    "hinh_anh_chung": "shared_image_url",
    "question": "content",
    "content": "content",
    "cau_hoi": "content",
    "option_a": "option_a",
    "a": "option_a",
    "option_b": "option_b",
    "b": "option_b",
    "option_c": "option_c",
    "c": "option_c",
    "option_d": "option_d",
    "d": "option_d",
    "answer": "correct_answer",
    "correct_answer": "correct_answer",
    "dap_an": "correct_answer",
    "explanation": "explanation",
    "giai_thich": "explanation",
    "audio_url": "audio_url",
    "audio": "audio_url",
    "image_url": "image_url",
    "image": "image_url",
    "hinh_anh": "image_url",
}

DOCUMENT_REQUIRED_FIELDS = {
    "part",
    "content",
    "option_a",
    "option_b",
    "option_c",
    "option_d",
    "correct_answer",
}


def infer_section_from_part(part: int | str | None) -> str:
    try:
        part_number = int(part) if part is not None else 0
    except (TypeError, ValueError):
        part_number = 0
    return "listening" if part_number and part_number <= 4 else "reading"


def normalize_difficulty(value: str | None) -> str:
    normalized = (value or "medium").strip().lower()
    if normalized not in {"easy", "medium", "hard"}:
        raise HTTPException(status_code=400, detail="difficulty must be easy, medium, or hard")
    return normalized


def normalize_document_field_name(raw: str) -> str | None:
    normalized = unicodedata.normalize("NFKD", raw.strip().lower())
    normalized = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    normalized = re.sub(r"[^a-z0-9]+", "_", normalized).strip("_")
    return DOCUMENT_FIELD_ALIASES.get(normalized)


def read_json_question_payload(file: UploadFile) -> list[dict]:
    try:
        payload = json.loads(file.file.read().decode("utf-8"))
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"File JSON không hợp lệ: {exc}") from exc

    if not isinstance(payload, list):
        raise HTTPException(status_code=400, detail="File JSON phải chứa một danh sách câu hỏi ở cấp gốc.")
    return payload


def extract_docx_text(file_bytes: bytes) -> str:
    try:
        with zipfile.ZipFile(io.BytesIO(file_bytes)) as archive:
            document_xml = archive.read("word/document.xml")
    except KeyError as exc:
        raise HTTPException(status_code=400, detail="File .docx không có nội dung tài liệu hợp lệ.") from exc
    except zipfile.BadZipFile as exc:
        raise HTTPException(status_code=400, detail="File Word không hợp lệ.") from exc

    namespace = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
    root = ET.fromstring(document_xml)
    paragraphs: list[str] = []
    for paragraph in root.findall(".//w:p", namespace):
        texts = [node.text or "" for node in paragraph.findall(".//w:t", namespace)]
        joined = "".join(texts).strip()
        if joined:
            paragraphs.append(joined)

    return "\n".join(paragraphs).strip()


def extract_pdf_text(file_bytes: bytes) -> str:
    try:
        from pypdf import PdfReader
    except ImportError as exc:
        raise HTTPException(
            status_code=500,
            detail="Tính năng nhập PDF cần thư viện pypdf. Hãy cài lại dependencies của backend.",
        ) from exc

    try:
        reader = PdfReader(io.BytesIO(file_bytes))
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"File PDF không hợp lệ: {exc}") from exc

    pages = [page.extract_text() or "" for page in reader.pages]
    text = "\n".join(page.strip() for page in pages if page and page.strip()).strip()
    if not text:
        raise HTTPException(
            status_code=400,
            detail="Không thể đọc chữ từ file PDF. Hãy dùng PDF có chữ thật hoặc tải file .docx.",
        )
    return text


def extract_supported_document_text(file: UploadFile) -> str:
    filename = (file.filename or "").lower()
    file_bytes = file.file.read()

    if filename.endswith(".docx"):
        text = extract_docx_text(file_bytes)
    elif filename.endswith(".pdf"):
        text = extract_pdf_text(file_bytes)
    else:
        raise HTTPException(status_code=400, detail="Chỉ hỗ trợ file .docx và .pdf.")

    if not text.strip():
        raise HTTPException(status_code=400, detail="Không thể đọc nội dung từ file đã tải lên.")
    return text


def parse_structured_question_block(block: str, block_index: int) -> dict:
    parsed: dict[str, str] = {}
    current_field: str | None = None
    buffer: list[str] = []

    def flush_current_field() -> None:
        nonlocal current_field, buffer
        if current_field is None:
            return
        parsed[current_field] = "\n".join(buffer).strip()
        current_field = None
        buffer = []

    for raw_line in block.splitlines():
        stripped_line = raw_line.strip()
        field_match = re.match(r"^([^:]{1,40})\s*:\s*(.*)$", stripped_line)
        normalized_field = None
        if field_match:
            normalized_field = normalize_document_field_name(field_match.group(1))

        if normalized_field:
            flush_current_field()
            current_field = normalized_field
            initial_value = field_match.group(2).strip()
            buffer = [initial_value] if initial_value else []
            continue

        if current_field is None:
            if stripped_line:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Định dạng ở khối câu hỏi {block_index} không hợp lệ. "
                        "Mỗi khối phải dùng các nhãn như QUESTION:, A:, B:, ANSWER:."
                    ),
                )
            continue

        buffer.append(raw_line.rstrip())

    flush_current_field()

    missing_fields = sorted(field for field in DOCUMENT_REQUIRED_FIELDS if not parsed.get(field))
    if missing_fields:
        raise HTTPException(
            status_code=400,
            detail=f"Khối câu hỏi {block_index} đang thiếu các trường bắt buộc: {', '.join(missing_fields)}",
        )

    try:
        part = int(str(parsed["part"]).strip())
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=f"Khối câu hỏi {block_index} có giá trị PART không hợp lệ.") from exc

    try:
        question_order = int(str(parsed.get("question_order", "1")).strip() or "1")
    except ValueError as exc:
        raise HTTPException(
            status_code=400,
            detail=f"Khối câu hỏi {block_index} có QUESTION_ORDER không hợp lệ.",
        ) from exc

    correct_answer = str(parsed["correct_answer"]).strip().upper()

    return {
        "part": part,
        "section": parsed.get("section"),
        "difficulty": parsed.get("difficulty"),
        "group_key": parsed.get("group_key"),
        "question_order": question_order,
        "instructions": parsed.get("instructions"),
        "shared_content": parsed.get("shared_content"),
        "shared_audio_url": parsed.get("shared_audio_url"),
        "shared_image_url": parsed.get("shared_image_url"),
        "content": parsed["content"],
        "option_a": parsed["option_a"],
        "option_b": parsed["option_b"],
        "option_c": parsed["option_c"],
        "option_d": parsed["option_d"],
        "correct_answer": correct_answer,
        "explanation": parsed.get("explanation"),
        "audio_url": parsed.get("audio_url"),
        "image_url": parsed.get("image_url"),
    }


def parse_structured_document_questions(text: str) -> list[dict]:
    normalized_text = text.replace("\r\n", "\n").replace("\r", "\n").strip()
    blocks = [
        block.strip()
        for block in re.split(r"(?m)^\s*={3,}\s*$", normalized_text)
        if block.strip()
    ]

    if not blocks:
        raise HTTPException(
            status_code=400,
            detail="Tài liệu đang rỗng hoặc thiếu dòng ngăn cách. Hãy dùng === giữa các khối câu hỏi.",
        )

    return [
        parse_structured_question_block(block, index + 1)
        for index, block in enumerate(blocks)
    ]


def import_question_payload(
    db: Session,
    *,
    staff: User,
    payload: list[dict],
) -> list[int]:
    created_ids: list[int] = []
    for index, item in enumerate(payload, start=1):
        if not isinstance(item, dict):
            raise HTTPException(status_code=400, detail=f"Câu hỏi số {index} phải có định dạng object.")

        try:
            question = create_question_record(
                db,
                staff=staff,
                part=int(item.get("part")),
                section=item.get("section"),
                difficulty=item.get("difficulty"),
                group_key=item.get("group_key"),
                question_order=int(item.get("question_order", 1)),
                instructions=item.get("instructions"),
                shared_content=item.get("shared_content"),
                shared_audio_url=item.get("shared_audio_url"),
                shared_image_url=item.get("shared_image_url"),
                content=str(item.get("content", "")),
                option_a=str(item.get("option_a", "")),
                option_b=str(item.get("option_b", "")),
                option_c=str(item.get("option_c", "")),
                option_d=str(item.get("option_d", "")),
                correct_answer=str(item.get("correct_answer", "")),
                explanation=item.get("explanation"),
                audio_url=item.get("audio_url"),
                image_url=item.get("image_url"),
            )
        except HTTPException as exc:
            raise HTTPException(
                status_code=exc.status_code,
                detail=f"Câu hỏi số {index}: {exc.detail}",
            ) from exc

        created_ids.append(question.id)
    return created_ids


def create_published_test_record(
    db: Session,
    *,
    staff: User,
    title: str,
    description: str | None,
    test_type: str,
    part: int | None,
    question_ids: list[int],
) -> PublishedTest:
    normalized_title = title.strip()
    if not normalized_title:
        raise HTTPException(status_code=400, detail="Tên đề không được để trống.")

    normalized_ids = [int(question_id) for question_id in question_ids]
    if not normalized_ids:
        raise HTTPException(status_code=400, detail="Danh sách câu hỏi không được để trống.")

    questions = db.query(Question).filter(Question.id.in_(normalized_ids)).all()
    question_map = {question.id: question for question in questions}

    missing_ids = [question_id for question_id in normalized_ids if question_id not in question_map]
    if missing_ids:
        raise HTTPException(
            status_code=400,
            detail=f"Một số question_id không hợp lệ: {', '.join(str(item) for item in missing_ids[:10])}",
        )

    unpublished_ids = [
        question_id
        for question_id in normalized_ids
        if get_question_approval_status(question_map[question_id]) != "approved"
    ]
    if unpublished_ids:
        raise HTTPException(
            status_code=400,
            detail="Chỉ câu hỏi đã được duyệt mới được đưa vào kho đề học sinh.",
        )

    published_test = PublishedTest(
        title=normalized_title,
        description=(description or "").strip() or None,
        test_type=test_type,
        part=part,
        status="published",
        total_questions=len(normalized_ids),
        created_by=staff.id,
    )
    db.add(published_test)
    db.flush()

    for index, question_id in enumerate(normalized_ids, start=1):
        db.add(
            PublishedTestItem(
                published_test_id=published_test.id,
                question_id=question_id,
                display_order=index,
            )
        )
    db.flush()
    return published_test


def build_question_source_hash(
    *,
    part: int,
    group_key: str | None,
    content: str,
    option_a: str,
    option_b: str,
    option_c: str,
    option_d: str,
) -> str:
    raw = "||".join(
        [
            str(part),
            (group_key or "").strip().lower(),
            content.strip().lower(),
            option_a.strip().lower(),
            option_b.strip().lower(),
            option_c.strip().lower(),
            option_d.strip().lower(),
        ]
    )
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def get_question_group_key(question: Question) -> str | None:
    return question.question_group.group_key if getattr(question, "question_group", None) else question.group_key


def get_question_instructions(question: Question) -> str | None:
    return question.question_group.instructions if getattr(question, "question_group", None) else question.instructions


def get_question_shared_content(question: Question) -> str | None:
    return question.question_group.shared_content if getattr(question, "question_group", None) else question.shared_content


def get_question_shared_audio_url(question: Question) -> str | None:
    return question.question_group.shared_audio_url if getattr(question, "question_group", None) else question.shared_audio_url


def get_question_shared_image_url(question: Question) -> str | None:
    return question.question_group.shared_image_url if getattr(question, "question_group", None) else question.shared_image_url


def get_question_difficulty(question: Question) -> str:
    return (question.workflow.difficulty if getattr(question, "workflow", None) else question.difficulty) or "medium"


def get_question_approval_status(question: Question) -> str:
    return (question.workflow.approval_status if getattr(question, "workflow", None) else question.approval_status) or "approved"


def get_question_review_note(question: Question) -> str | None:
    return question.workflow.review_note if getattr(question, "workflow", None) else question.review_note


def get_question_submitted_by(question: Question) -> int | None:
    return question.workflow.submitted_by if getattr(question, "workflow", None) else question.submitted_by


def get_question_approved_by(question: Question) -> int | None:
    return question.workflow.approved_by if getattr(question, "workflow", None) else question.approved_by


def is_user_premium_active(user: User) -> bool:
    if (user.membership_plan or "basic").lower() != "premium":
        return False
    if user.premium_expires_at is None:
        return False
    return True


def serialize_premium_payment_request(item: PremiumPaymentRequest) -> dict:
    return {
        "id": item.id,
        "user_id": item.user_id,
        "months": item.months,
        "amount": item.amount,
        "status": item.status,
        "transaction_code": item.transaction_code,
        "note": item.note,
        "review_note": item.review_note,
        "reviewed_by": item.reviewed_by,
        "created_at": item.created_at,
        "reviewed_at": item.reviewed_at,
    }


def require_question_owner_or_admin(question: Question, staff: User) -> None:
    if staff.role != "teacher":
        return

    submitted_by = get_question_submitted_by(question)
    if submitted_by != staff.id:
        raise HTTPException(
            status_code=403,
            detail="Giáo viên chỉ được sửa câu hỏi do mình tạo.",
        )


def ensure_question_group(
    db: Session,
    *,
    part: int,
    section: str | None,
    group_key: str | None,
    instructions: str | None,
    shared_content: str | None,
    shared_audio_url: str | None,
    shared_image_url: str | None,
) -> QuestionGroup | None:
    normalized_group_key = (group_key or "").strip()
    if not normalized_group_key:
        return None

    question_group = (
        db.query(QuestionGroup)
        .filter(QuestionGroup.group_key == normalized_group_key)
        .first()
    )
    if question_group is None:
        question_group = QuestionGroup(
            group_key=normalized_group_key,
            part=part,
            section=section,
            instructions=instructions,
            shared_content=shared_content,
            shared_audio_url=shared_audio_url,
            shared_image_url=shared_image_url,
        )
        db.add(question_group)
        db.flush()
        return question_group

    question_group.part = part
    question_group.section = section
    question_group.instructions = instructions
    question_group.shared_content = shared_content
    question_group.shared_audio_url = shared_audio_url
    question_group.shared_image_url = shared_image_url
    db.flush()
    return question_group


def ensure_question_workflow(
    db: Session,
    *,
    question: Question,
    difficulty: str,
    approval_status: str,
    review_note: str | None,
    source_hash: str | None,
    submitted_by: int | None,
    approved_by: int | None,
) -> QuestionWorkflow:
    workflow = (
        db.query(QuestionWorkflow)
        .filter(QuestionWorkflow.question_id == question.id)
        .first()
    )
    if workflow is None:
        workflow = QuestionWorkflow(question_id=question.id)
        db.add(workflow)

    workflow.difficulty = difficulty
    workflow.approval_status = approval_status
    workflow.review_note = review_note
    workflow.source_hash = source_hash
    workflow.submitted_by = submitted_by
    workflow.approved_by = approved_by
    db.flush()
    return workflow


def create_question_record(
    db: Session,
    *,
    staff: User,
    part: int,
    section: str | None,
    difficulty: str | None,
    group_key: str | None,
    question_order: int,
    instructions: str | None,
    shared_content: str | None,
    shared_audio_url: str | None,
    shared_image_url: str | None,
    content: str,
    option_a: str,
    option_b: str,
    option_c: str,
    option_d: str,
    correct_answer: str,
    explanation: str | None,
    audio_url: str | None,
    image_url: str | None,
) -> Question:
    resolved_section = (section or infer_section_from_part(part)).strip().lower()
    if resolved_section not in ["listening", "reading"]:
        raise HTTPException(status_code=400, detail="section must be listening or reading")
    if question_order < 1:
        raise HTTPException(status_code=400, detail="question_order must be at least 1")
    if correct_answer not in ["A", "B", "C", "D"]:
        raise HTTPException(status_code=400, detail="correct_answer must be A, B, C, or D")

    resolved_difficulty = normalize_difficulty(difficulty)
    source_hash = build_question_source_hash(
        part=part,
        group_key=group_key,
        content=content,
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        option_d=option_d,
    )
    if db.query(QuestionWorkflow).filter(QuestionWorkflow.source_hash == source_hash).first():
        raise HTTPException(status_code=400, detail="Câu hỏi này đã tồn tại.")
    if db.query(Question).filter(Question.source_hash == source_hash).first():
        raise HTTPException(status_code=400, detail="Câu hỏi này đã tồn tại.")

    question_group = ensure_question_group(
        db,
        part=part,
        section=resolved_section,
        group_key=group_key,
        instructions=(instructions or "").strip() or None,
        shared_content=(shared_content or "").strip() or None,
        shared_audio_url=shared_audio_url,
        shared_image_url=(shared_image_url or "").strip() or None,
    )

    question = Question(
        part=part,
        section=resolved_section,
        question_group_id=question_group.id if question_group else None,
        difficulty=resolved_difficulty,
        approval_status="pending" if staff.role == "teacher" else "approved",
        group_key=(group_key or "").strip() or None,
        question_order=question_order,
        instructions=(instructions or "").strip() or None,
        shared_content=(shared_content or "").strip() or None,
        shared_audio_url=shared_audio_url,
        shared_image_url=(shared_image_url or "").strip() or None,
        content=content,
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        option_d=option_d,
        correct_answer=correct_answer,
        explanation=explanation,
        audio_url=audio_url,
        image_url=(image_url or "").strip() or None,
        source_hash=source_hash,
        submitted_by=staff.id,
        approved_by=staff.id if staff.role != "teacher" else None,
    )
    db.add(question)
    db.flush()
    ensure_question_workflow(
        db,
        question=question,
        difficulty=resolved_difficulty,
        approval_status=question.approval_status,
        review_note=None,
        source_hash=source_hash,
        submitted_by=staff.id,
        approved_by=staff.id if staff.role != "teacher" else None,
    )
    return question


def save_upload_file(
    file: UploadFile,
    folder: Path,
    allowed_content_types: list[str],
) -> str:
    if file.content_type not in allowed_content_types:
        raise HTTPException(
            status_code=400,
            detail=f"Loại tệp không hợp lệ: {file.content_type}",
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
    approval_status: str | None = None,
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    query = db.query(Question).outerjoin(
        QuestionWorkflow,
        QuestionWorkflow.question_id == Question.id,
    )

    if part is not None:
        query = query.filter(Question.part == part)
    if approval_status is not None:
        query = query.filter(
            (QuestionWorkflow.approval_status == approval_status)
            | (QuestionWorkflow.approval_status.is_(None) & (Question.approval_status == approval_status))
        )
    if staff.role == "teacher":
        query = query.filter(
            (QuestionWorkflow.submitted_by == staff.id)
            | (QuestionWorkflow.submitted_by.is_(None) & (Question.submitted_by == staff.id))
        )

    results = query.limit(300).all()

    return [
        {
            "id": q.id,
            "part": q.part,
            "section": q.section or infer_section_from_part(q.part),
            "difficulty": get_question_difficulty(q),
            "approval_status": get_question_approval_status(q),
            "group_key": get_question_group_key(q),
            "question_order": q.question_order,
            "instructions": get_question_instructions(q),
            "shared_content": get_question_shared_content(q),
            "shared_audio_url": get_question_shared_audio_url(q),
            "shared_image_url": get_question_shared_image_url(q),
            "content": q.content,
            "option_a": q.option_a,
            "option_b": q.option_b,
            "option_c": q.option_c,
            "option_d": q.option_d,
            "correct_answer": q.correct_answer,
            "audio_url": q.audio_url,
            "image_url": q.image_url,
            "explanation": q.explanation,
            "review_note": get_question_review_note(q),
            "submitted_by": get_question_submitted_by(q),
            "approved_by": get_question_approved_by(q),
        }
        for q in results
    ]


@router.post("/questions")
def create_question_admin(
    part: int = Form(...),
    section: str | None = Form(default=None),
    difficulty: str = Form(default="medium"),
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
    staff: User = Depends(require_staff),
):
    if correct_answer not in ["A", "B", "C", "D"]:
        raise HTTPException(status_code=400, detail="correct_answer must be A, B, C, or D")

    resolved_section = (section or infer_section_from_part(part)).strip().lower()
    if resolved_section not in ["listening", "reading"]:
        raise HTTPException(status_code=400, detail="section must be listening or reading")
    if question_order < 1:
        raise HTTPException(status_code=400, detail="question_order must be at least 1")
    resolved_difficulty = normalize_difficulty(difficulty)

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

    question = create_question_record(
        db,
        staff=staff,
        part=part,
        section=resolved_section,
        difficulty=resolved_difficulty,
        group_key=group_key,
        question_order=question_order,
        instructions=instructions,
        shared_content=shared_content,
        shared_audio_url=shared_audio_url,
        shared_image_url=direct_shared_image_url,
        content=content,
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        option_d=option_d,
        correct_answer=correct_answer,
        explanation=explanation,
        audio_url=audio_url,
        image_url=direct_image_url,
    )
    db.commit()
    db.refresh(question)

    return {
        "message": "Tạo câu hỏi thành công.",
        "id": question.id,
        "part": question.part,
        "section": question.section,
        "difficulty": get_question_difficulty(question),
        "approval_status": get_question_approval_status(question),
        "group_key": get_question_group_key(question),
        "question_order": question.question_order,
        "instructions": get_question_instructions(question),
        "shared_content": get_question_shared_content(question),
        "shared_audio_url": get_question_shared_audio_url(question),
        "shared_image_url": get_question_shared_image_url(question),
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
    difficulty: str = Form(default="medium"),
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
    staff: User = Depends(require_staff),
):
    if correct_answer not in ["A", "B", "C", "D"]:
        raise HTTPException(status_code=400, detail="correct_answer must be A, B, C, or D")

    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Không tìm thấy câu hỏi.")
    require_question_owner_or_admin(question, staff)

    resolved_section = (section or infer_section_from_part(part)).strip().lower()
    if resolved_section not in ["listening", "reading"]:
        raise HTTPException(status_code=400, detail="section must be listening or reading")
    if question_order < 1:
        raise HTTPException(status_code=400, detail="question_order must be at least 1")
    resolved_difficulty = normalize_difficulty(difficulty)
    source_hash = build_question_source_hash(
        part=part,
        group_key=group_key,
        content=content,
        option_a=option_a,
        option_b=option_b,
        option_c=option_c,
        option_d=option_d,
    )
    existing_workflow = (
        db.query(QuestionWorkflow)
        .filter(QuestionWorkflow.source_hash == source_hash, QuestionWorkflow.question_id != question_id)
        .first()
    )
    if existing_workflow:
        raise HTTPException(status_code=400, detail="Câu hỏi này đã tồn tại.")
    existing_question = (
        db.query(Question)
        .filter(Question.source_hash == source_hash, Question.id != question_id)
        .first()
    )
    if existing_question:
        raise HTTPException(status_code=400, detail="Câu hỏi này đã tồn tại.")

    old_audio_url = question.audio_url
    old_image_url = question.image_url
    old_shared_audio_url = question.shared_audio_url
    old_shared_image_url = question.shared_image_url

    question.part = part
    question.section = resolved_section
    question_group = ensure_question_group(
        db,
        part=part,
        section=resolved_section,
        group_key=group_key,
        instructions=(instructions or "").strip() or None,
        shared_content=(shared_content or "").strip() or None,
        shared_audio_url=question.shared_audio_url,
        shared_image_url=(shared_image_url or "").strip() or None,
    )
    question.question_group_id = question_group.id if question_group else None
    question.difficulty = resolved_difficulty
    question.source_hash = source_hash
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
    if staff.role == "teacher":
        question.approval_status = "pending"
        question.approved_by = None
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

    ensure_question_group(
        db,
        part=question.part,
        section=question.section,
        group_key=question.group_key,
        instructions=question.instructions,
        shared_content=question.shared_content,
        shared_audio_url=question.shared_audio_url,
        shared_image_url=question.shared_image_url,
    )
    ensure_question_workflow(
        db,
        question=question,
        difficulty=question.difficulty,
        approval_status=question.approval_status,
        review_note=question.review_note,
        source_hash=question.source_hash,
        submitted_by=question.submitted_by,
        approved_by=question.approved_by,
    )

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
        "message": "Cập nhật câu hỏi thành công.",
        "id": question.id,
        "part": question.part,
        "section": question.section,
        "difficulty": get_question_difficulty(question),
        "approval_status": get_question_approval_status(question),
        "group_key": get_question_group_key(question),
        "question_order": question.question_order,
        "instructions": get_question_instructions(question),
        "shared_content": get_question_shared_content(question),
        "shared_audio_url": get_question_shared_audio_url(question),
        "shared_image_url": get_question_shared_image_url(question),
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
        raise HTTPException(status_code=404, detail="Không tìm thấy câu hỏi.")

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

    return {"message": "Xóa câu hỏi thành công."}


@router.post("/questions/import-json")
def import_questions_json(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    if (file.filename or "").lower().endswith(".json") is False:
        raise HTTPException(status_code=400, detail="Chỉ hỗ trợ file .json.")

    payload = read_json_question_payload(file)
    created_ids = import_question_payload(db, staff=staff, payload=payload)

    db.commit()
    return {
        "message": "Nhập câu hỏi thành công.",
        "count": len(created_ids),
        "question_ids": created_ids,
    }


@router.post("/questions/preview-json")
def preview_questions_json(
    file: UploadFile = File(...),
    staff: User = Depends(require_staff),
):
    if (file.filename or "").lower().endswith(".json") is False:
        raise HTTPException(status_code=400, detail="Chỉ hỗ trợ file .json.")

    payload = read_json_question_payload(file)
    return {
        "message": "Tạo bản xem trước thành công.",
        "count": len(payload),
        "questions": payload,
        "submission_status": "pending" if staff.role == "teacher" else "approved",
    }


@router.post("/questions/import-document")
def import_questions_document(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    text = extract_supported_document_text(file)
    payload = parse_structured_document_questions(text)
    created_ids = import_question_payload(db, staff=staff, payload=payload)

    db.commit()
    return {
        "message": "Nhập câu hỏi từ tài liệu thành công.",
        "count": len(created_ids),
        "question_ids": created_ids,
        "source_type": "document",
    }


@router.post("/questions/preview-document")
def preview_questions_document(
    file: UploadFile = File(...),
    staff: User = Depends(require_staff),
):
    text = extract_supported_document_text(file)
    payload = parse_structured_document_questions(text)
    return {
        "message": "Tạo bản xem trước thành công.",
        "count": len(payload),
        "questions": payload,
        "source_type": "document",
        "submission_status": "pending" if staff.role == "teacher" else "approved",
    }


@router.post("/published-tests")
def create_published_test(
    payload: PublishedTestCreateRequest,
    db: Session = Depends(get_db),
    staff: User = Depends(require_roles("admin", "moderator")),
):
    published_test = create_published_test_record(
        db,
        staff=staff,
        title=payload.title,
        description=payload.description,
        test_type=payload.test_type,
        part=payload.part,
        question_ids=payload.question_ids,
    )
    db.commit()
    db.refresh(published_test)

    return {
        "message": "Đã tạo đề phát hành thành công.",
        **serialize_published_test_summary(published_test),
    }


@router.get("/published-tests")
def list_published_tests_admin(
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    tests = (
        db.query(PublishedTest)
        .order_by(PublishedTest.published_at.desc(), PublishedTest.id.desc())
        .all()
    )
    return [serialize_published_test_summary(test) for test in tests]


@router.get("/published-tests/{published_test_id}")
def get_published_test_admin(
    published_test_id: int,
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    published_test = db.query(PublishedTest).filter(PublishedTest.id == published_test_id).first()
    if not published_test:
        raise HTTPException(status_code=404, detail="Không tìm thấy đề đã phát hành.")

    questions = get_published_test_questions(db, published_test.id)
    return {
        **serialize_published_test_summary(published_test),
        "questions": [serialize_question_public(question) for question in questions],
    }


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


@router.get("/attempts/{attempt_id}")
def get_attempt_detail_admin(
    attempt_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    attempt = db.query(TestAttempt).filter(TestAttempt.id == attempt_id).first()

    if not attempt:
        raise HTTPException(status_code=404, detail="Không tìm thấy bài làm.")

    detail = build_attempt_detail_response(attempt, db)
    owner = db.query(User).filter(User.id == attempt.user_id).first()
    detail["user_id"] = attempt.user_id
    detail["user_email"] = owner.email if owner else None
    detail["user_full_name"] = owner.full_name if owner else None
    return detail


@router.get("/premium-payment-requests")
def list_premium_payment_requests(
    status: str | None = Query(default=None),
    db: Session = Depends(get_db),
    staff: User = Depends(require_roles("admin", "moderator")),
):
    query = db.query(PremiumPaymentRequest)
    if status:
        query = query.filter(PremiumPaymentRequest.status == status)

    rows = query.order_by(
        PremiumPaymentRequest.created_at.desc(),
        PremiumPaymentRequest.id.desc(),
    ).all()

    users = {
        user.id: user
        for user in db.query(User).filter(User.id.in_([row.user_id for row in rows])).all()
    }

    result = []
    for row in rows:
        owner = users.get(row.user_id)
        result.append(
            {
                **serialize_premium_payment_request(row),
                "user_full_name": owner.full_name if owner else None,
                "user_email": owner.email if owner else None,
            }
        )
    return result


@router.put("/premium-payment-requests/{request_id}")
def review_premium_payment_request(
    request_id: int,
    payload: PremiumPaymentReviewRequest,
    db: Session = Depends(get_db),
    staff: User = Depends(require_roles("admin", "moderator")),
):
    if payload.status not in {"approved", "rejected"}:
        raise HTTPException(status_code=400, detail="Trạng thái duyệt không hợp lệ.")

    payment_request = (
        db.query(PremiumPaymentRequest)
        .filter(PremiumPaymentRequest.id == request_id)
        .first()
    )
    if not payment_request:
        raise HTTPException(status_code=404, detail="Không tìm thấy yêu cầu thanh toán.")

    if payment_request.status != "pending":
        raise HTTPException(status_code=400, detail="Yêu cầu này đã được xử lý trước đó.")

    payment_request.status = payload.status
    payment_request.review_note = (payload.review_note or "").strip() or None
    payment_request.reviewed_by = staff.id
    payment_request.reviewed_at = datetime.now(timezone.utc)

    user = db.query(User).filter(User.id == payment_request.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng.")

    if payload.status == "approved":
        now = datetime.now(timezone.utc)
        effective_start = now
        if user.premium_expires_at is not None:
            current_expiry = user.premium_expires_at
            if current_expiry.tzinfo is None:
                current_expiry = current_expiry.replace(tzinfo=timezone.utc)
            if current_expiry > now:
                effective_start = current_expiry

        user.membership_plan = "premium"
        user.premium_started_at = user.premium_started_at or now
        user.premium_expires_at = effective_start + timedelta(days=30 * payment_request.months)
        user.premium_cancel_at_period_end = False

    db.commit()
    db.refresh(payment_request)
    db.refresh(user)

    return {
        "message": (
            "Đã duyệt yêu cầu thanh toán và kích hoạt Premium."
            if payload.status == "approved"
            else "Đã từ chối yêu cầu thanh toán."
        ),
        "request": serialize_premium_payment_request(payment_request),
        "user_membership_plan": user.membership_plan,
    }


@router.put("/users/{user_id}/role")
def update_user_role(
    user_id: int,
    role: str = Query(...),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    if role not in ["admin", "user", "teacher", "moderator"]:
        raise HTTPException(status_code=400, detail="Vai trò không hợp lệ.")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng.")

    user.role = role
    db.commit()
    db.refresh(user)

    return {
        "message": "Cập nhật vai trò người dùng thành công.",
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
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng.")

    user.password_hash = hash_password(new_password)
    revoke_user_refresh_tokens(db, user.id)
    db.commit()

    return {"message": "Đặt lại mật khẩu thành công."}


@router.delete("/users/{user_id}")
def delete_user_admin(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng.")

    if user.id == admin.id:
        raise HTTPException(status_code=400, detail="Bạn không thể tự xóa tài khoản quản trị của chính mình.")

    attempts = db.query(TestAttempt).filter(TestAttempt.user_id == user_id).all()
    attempt_ids = [attempt.id for attempt in attempts]

    if attempt_ids:
        db.query(TestAttemptAnswer).filter(
            TestAttemptAnswer.attempt_id.in_(attempt_ids)
        ).delete(synchronize_session=False)

    db.query(PremiumPaymentRequest).filter(
        PremiumPaymentRequest.reviewed_by == user_id
    ).update({"reviewed_by": None}, synchronize_session=False)
    db.query(PremiumPaymentRequest).filter(
        PremiumPaymentRequest.user_id == user_id
    ).delete(synchronize_session=False)

    db.query(TestAttempt).filter(TestAttempt.user_id == user_id).delete(synchronize_session=False)
    db.query(UserBookmark).filter(UserBookmark.user_id == user_id).delete(synchronize_session=False)
    db.query(UserStudiedWord).filter(UserStudiedWord.user_id == user_id).delete(synchronize_session=False)
    db.query(UserProgress).filter(UserProgress.user_id == user_id).delete(synchronize_session=False)
    db.query(RefreshToken).filter(RefreshToken.user_id == user_id).delete(synchronize_session=False)

    db.delete(user)
    db.commit()

    return {"message": "Xóa người dùng thành công.", "user_id": user_id}


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
        raise HTTPException(status_code=400, detail="Chủ đề này đã tồn tại.")

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
    
    return {"message": "Tạo chủ đề thành công.", "id": topic.id}

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
        raise HTTPException(status_code=400, detail="Chủ đề này đã tồn tại.")
    
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
    return {"message": "Cập nhật chủ đề thành công."}

@router.delete("/topics/{topic_id}")
def delete_topic_admin(
    topic_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    topic = db.query(Topic).filter(Topic.id == topic_id).first()
    if not topic:
        raise HTTPException(status_code=404, detail="Không tìm thấy chủ đề.")

    words_count = db.query(VocabularyWord).filter(
        VocabularyWord.topic_id == topic_id
    ).count()
    if words_count > 0:
        raise HTTPException(
            status_code=400,
            detail="Không thể xóa chủ đề khi vẫn còn từ vựng bên trong.",
        )
    
    delete_file_if_exists(topic.image_url)
    db.delete(topic)
    db.commit()
    return {"message": "Xóa chủ đề thành công."}


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
        raise HTTPException(status_code=400, detail="Từ vựng này đã tồn tại.")

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

    return {"message": "Tạo từ vựng thành công.", "id": word.id}

@router.put("/vocabulary/{word_id}")
def update_word_admin(
    word_id: int,
    payload: VocabularyUpdatePayload,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    word_db = db.query(VocabularyWord).filter(VocabularyWord.id == word_id).first()
    if not word_db:
        raise HTTPException(status_code=404, detail="Không tìm thấy từ vựng.")

    if payload.word is not None:
        existing = db.query(VocabularyWord).filter(VocabularyWord.word == payload.word, VocabularyWord.id != word_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Từ vựng này đã tồn tại.")
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
    
    return {"message": "Cập nhật từ vựng thành công.", "id": word_db.id}

@router.delete("/vocabulary/{word_id}")
def delete_word_admin(
    word_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    word = db.query(VocabularyWord).filter(VocabularyWord.id == word_id).first()
    if not word:
        raise HTTPException(status_code=404, detail="Không tìm thấy từ vựng.")

    # Xóa lịch sử học từ này của mọi User trước để tránh lỗi ForeignKey
    db.query(UserStudiedWord).filter(UserStudiedWord.word_id == word_id).delete()
    
    db.delete(word)
    db.commit()

    return {"message": "Xóa từ vựng thành công."}
