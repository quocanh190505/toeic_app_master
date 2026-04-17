import os
import random
import shutil
import uuid
import hashlib
from datetime import datetime, timezone
from collections import defaultdict

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user, require_admin, require_staff, require_roles
from app.models.entities import (
    PublishedTest,
    PublishedTestItem,
    Question,
    QuestionGroup,
    QuestionWorkflow,
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
    QuestionApprovalPayload,
    GeneratedTestRequest,
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

MINI_TEST_PART_QUESTION_COUNT = {
    1: 10,
    2: 10,
    3: 9,
    4: 9,
    5: 10,
    6: 10,
    7: 9,
}

FULL_TEST_GROUP_SIZE = {
    1: 1,
    2: 1,
    3: 3,
    4: 3,
    5: 1,
    6: 2,
    7: 3,
}

ALLOWED_DIFFICULTIES = {"easy", "medium", "hard"}
ALLOWED_APPROVAL_STATUSES = {"pending", "approved", "rejected"}
FULL_TEST_DIFFICULTY_DISTRIBUTION = {
    1: {"easy": 2, "medium": 2, "hard": 2},
    2: {"easy": 8, "medium": 9, "hard": 8},
    3: {"easy": 12, "medium": 15, "hard": 12},
    4: {"easy": 9, "medium": 12, "hard": 9},
    5: {"easy": 10, "medium": 10, "hard": 10},
    6: {"easy": 4, "medium": 6, "hard": 6},
    7: {"easy": 18, "medium": 18, "hard": 18},
}


def is_user_premium_active(user: User) -> bool:
    if (user.membership_plan or "basic").lower() != "premium":
        return False
    if user.premium_expires_at is None:
        return False
    expires_at = user.premium_expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    return expires_at >= datetime.now(timezone.utc)


def require_premium_feature(current_user: User, feature_name: str) -> None:
    if current_user.role in {"admin", "teacher", "moderator"}:
        return
    if is_user_premium_active(current_user):
        return
    raise HTTPException(
        status_code=403,
        detail=f"{feature_name} chỉ dành cho thành viên Premium.",
    )


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


def infer_section_from_part(part: int | str | None) -> str:
    try:
        part_number = int(part) if part is not None else 0
    except (TypeError, ValueError):
        part_number = 0
    return "listening" if part_number and part_number <= 4 else "reading"


def normalize_difficulty(value: str | None) -> str:
    normalized = (value or "medium").strip().lower()
    if normalized not in ALLOWED_DIFFICULTIES:
        raise HTTPException(status_code=400, detail="Độ khó không hợp lệ.")
    return normalized


def normalize_approval_status(value: str | None, *, default: str = "approved") -> str:
    normalized = (value or default).strip().lower()
    if normalized not in ALLOWED_APPROVAL_STATUSES:
        raise HTTPException(status_code=400, detail="Trạng thái duyệt không hợp lệ.")
    return normalized


def build_question_source_hash(*, part: int, group_key: str | None, content: str, option_a: str, option_b: str, option_c: str, option_d: str) -> str:
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
    workflow = getattr(question, "workflow", None)
    return (workflow.difficulty if workflow else getattr(question, "difficulty", None)) or "medium"


def get_question_approval_status(question: Question) -> str:
    workflow = getattr(question, "workflow", None)
    return (workflow.approval_status if workflow else getattr(question, "approval_status", None)) or "approved"


def get_question_review_note(question: Question) -> str | None:
    workflow = getattr(question, "workflow", None)
    return workflow.review_note if workflow else getattr(question, "review_note", None)


def get_question_submitted_by(question: Question) -> int | None:
    workflow = getattr(question, "workflow", None)
    return workflow.submitted_by if workflow else getattr(question, "submitted_by", None)


def get_question_approved_by(question: Question) -> int | None:
    workflow = getattr(question, "workflow", None)
    return workflow.approved_by if workflow else getattr(question, "approved_by", None)


def get_question_source_hash(question: Question) -> str | None:
    workflow = getattr(question, "workflow", None)
    return workflow.source_hash if workflow else getattr(question, "source_hash", None)


def ensure_question_not_duplicate(
    db: Session,
    *,
    source_hash: str,
    exclude_question_id: int | None = None,
) -> None:
    workflow_query = db.query(QuestionWorkflow).filter(QuestionWorkflow.source_hash == source_hash)
    if exclude_question_id is not None:
        workflow_query = workflow_query.filter(QuestionWorkflow.question_id != exclude_question_id)
    if workflow_query.first():
        raise HTTPException(
            status_code=400,
            detail="Câu hỏi này đã tồn tại hoặc bị trùng nội dung với câu hỏi khác.",
        )

    query = db.query(Question).filter(Question.source_hash == source_hash)
    if exclude_question_id is not None:
        query = query.filter(Question.id != exclude_question_id)
    if query.first():
        raise HTTPException(
            status_code=400,
            detail="Câu hỏi này đã tồn tại hoặc bị trùng nội dung với câu hỏi khác.",
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


def serialize_question_public(q: Question):
    return {
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
        "options": {
            "A": q.option_a,
            "B": q.option_b,
            "C": q.option_c,
            "D": q.option_d,
        },
        "audio_url": q.audio_url,
        "image_url": q.image_url,
        "review_note": get_question_review_note(q),
        "submitted_by": get_question_submitted_by(q),
        "approved_by": get_question_approved_by(q),
    }


def serialize_published_test_summary(test: PublishedTest) -> dict:
    return {
        "id": test.id,
        "title": test.title,
        "description": test.description,
        "test_type": test.test_type,
        "part": test.part,
        "status": test.status,
        "total_questions": test.total_questions,
        "published_at": test.published_at,
    }


def get_published_test_questions(db: Session, published_test_id: int) -> list[Question]:
    items = (
        db.query(PublishedTestItem)
        .filter(PublishedTestItem.published_test_id == published_test_id)
        .order_by(PublishedTestItem.display_order.asc(), PublishedTestItem.id.asc())
        .all()
    )
    return [item.question for item in items if item.question is not None]


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


def chunk_questions(questions, chunk_size: int):
    return [
        questions[index : index + chunk_size]
        for index in range(0, len(questions), chunk_size)
        if len(questions[index : index + chunk_size]) == chunk_size
    ]


def build_question_groups(questions: list[Question]) -> list[list[Question]]:
    grouped: dict[str, list[Question]] = {}
    standalone: list[list[Question]] = []

    for question in questions:
        key = (get_question_group_key(question) or "").strip()
        if key:
            grouped.setdefault(key, []).append(question)
        else:
            standalone.append([question])

    grouped_values = list(grouped.values())
    for group in grouped_values:
        group.sort(key=lambda item: (item.question_order, item.id))

    grouped_values.sort(key=lambda group: (group[0].id, group[0].question_order))
    standalone.sort(key=lambda group: group[0].id)

    return grouped_values + standalone


def get_approved_questions_query(db: Session, *, part: int | None = None):
    query = (
        db.query(Question)
        .outerjoin(QuestionWorkflow, QuestionWorkflow.question_id == Question.id)
        .filter(
            (QuestionWorkflow.approval_status == "approved")
            | (QuestionWorkflow.approval_status.is_(None) & (Question.approval_status == "approved"))
            | (QuestionWorkflow.approval_status.is_(None) & Question.approval_status.is_(None))
        )
    )
    if part is not None:
        query = query.filter(Question.part == part)
    return query


def difficulty_sequence_from_distribution(distribution: dict[str, int]) -> list[str]:
    sequence: list[str] = []
    for difficulty, count in distribution.items():
        sequence.extend([difficulty] * count)
    random.shuffle(sequence)
    return sequence


def pick_questions_for_difficulty(
    groups: list[list[Question]],
    target_count: int,
    used_question_ids: set[int],
) -> list[list[Question]]:
    available_groups = [
        group for group in groups
        if all(question.id not in used_question_ids for question in group)
    ]
    picked = pick_question_groups_exactly(available_groups, target_count)
    if picked is None:
        raise HTTPException(
            status_code=400,
            detail=f"Not enough approved questions to satisfy {target_count} items for one difficulty band.",
        )
    return picked


def pick_question_groups_exactly(
    available_groups: list[list[Question]],
    target_question_count: int,
    attempts: int = 200,
) -> list[list[Question]] | None:
    for _ in range(attempts):
        shuffled_groups = available_groups[:]
        random.shuffle(shuffled_groups)

        selected_groups: list[list[Question]] = []
        remaining = target_question_count

        for group in shuffled_groups:
            group_size = len(group)
            if group_size > remaining:
                continue

            selected_groups.append(group)
            remaining -= group_size

            if remaining == 0:
                selected_groups.sort(key=lambda group: group[0].id)
                return selected_groups

    return None


def select_full_test_questions(db: Session):
    selected = []

    for part, count in FULL_TEST_DISTRIBUTION.items():
        group_size = FULL_TEST_GROUP_SIZE[part]
        ordered_questions = (
            get_approved_questions_query(db, part=part)
            .order_by(Question.id.asc())
            .all()
        )

        if len(ordered_questions) < count:
            raise HTTPException(
                status_code=400,
                detail=f"Not enough questions for part {part}. Need at least {count} questions.",
            )

        has_explicit_groups = any(
            (question.group_key or "").strip() for question in ordered_questions
        )

        if has_explicit_groups:
            available_groups = build_question_groups(ordered_questions)
            picked_groups = pick_question_groups_exactly(available_groups, count)

            if picked_groups is None:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Not enough valid grouped data for part {part}. "
                        f"Need groups that sum exactly to {count} questions."
                    ),
                )
        else:
            available_groups = chunk_questions(ordered_questions, group_size)
            required_group_count = count // group_size

            if required_group_count * group_size != count:
                raise HTTPException(
                    status_code=500,
                    detail=f"Cấu hình phân bố full test cho part {part} không hợp lệ.",
                )

            if len(available_groups) < required_group_count:
                raise HTTPException(
                    status_code=400,
                    detail=(
                        f"Not enough grouped questions for part {part}. "
                        f"Need at least {required_group_count} groups of {group_size}."
                    ),
                )

            picked_groups = random.sample(available_groups, required_group_count)
            picked_groups.sort(key=lambda group: group[0].id)

        for group in picked_groups:
            selected.extend(group)

    return selected


def select_structured_questions_for_part(
    db: Session,
    *,
    part: int,
    target_question_count: int,
) -> list[Question]:
    group_size = FULL_TEST_GROUP_SIZE[part]
    ordered_questions = (
        get_approved_questions_query(db, part=part)
        .order_by(Question.id.asc())
        .all()
    )

    if not ordered_questions:
        raise HTTPException(
            status_code=400,
            detail=f"No questions available for part {part}.",
        )

    effective_target_question_count = min(
        target_question_count,
        len(ordered_questions),
    )

    has_explicit_groups = any(
        (question.group_key or "").strip() for question in ordered_questions
    )

    if has_explicit_groups:
        available_groups = build_question_groups(ordered_questions)
        picked_groups = pick_question_groups_exactly(
            available_groups,
            effective_target_question_count,
        )
        if picked_groups is None:
            # Fallback for mini tests: return as many full groups as currently available
            # instead of blocking the user when a part has fewer questions than target.
            running_total = 0
            picked_groups = []
            for group in available_groups:
                group_size = len(group)
                if running_total + group_size > effective_target_question_count:
                    continue
                picked_groups.append(group)
                running_total += group_size

            if not picked_groups:
                picked_groups = available_groups[:1]
    else:
        available_groups = chunk_questions(ordered_questions, group_size)
        required_group_count = effective_target_question_count // group_size

        if required_group_count * group_size != effective_target_question_count:
            raise HTTPException(
                status_code=500,
                detail=f"Cấu hình phân bố mini test cho part {part} không hợp lệ.",
            )

        if not available_groups:
            available_groups = [[question] for question in ordered_questions]
            required_group_count = min(
                effective_target_question_count,
                len(available_groups),
            )
        else:
            required_group_count = min(required_group_count, len(available_groups))

        picked_groups = random.sample(available_groups, required_group_count)
        picked_groups.sort(key=lambda group: group[0].id)

    selected: list[Question] = []
    for group in picked_groups:
        selected.extend(group)

    return selected


def generate_full_test_by_difficulty(
    db: Session,
    *,
    avoid_question_ids: set[int] | None = None,
) -> list[Question]:
    used_question_ids = set(avoid_question_ids or set())
    selected: list[Question] = []

    for part, distribution in FULL_TEST_DIFFICULTY_DISTRIBUTION.items():
        part_selected_groups: list[list[Question]] = []
        for difficulty, target_count in distribution.items():
            part_questions = (
                get_approved_questions_query(db, part=part)
                .filter(
                    (QuestionWorkflow.difficulty == difficulty)
                    | (QuestionWorkflow.difficulty.is_(None) & (Question.difficulty == difficulty))
                )
                .order_by(Question.id.asc())
                .all()
            )

            if not part_questions:
                raise HTTPException(
                    status_code=400,
                    detail=f"No approved questions for part {part} with difficulty {difficulty}.",
                )

            groups = build_question_groups(part_questions)
            picked_groups = pick_questions_for_difficulty(
                groups,
                target_count,
                used_question_ids,
            )

            for group in picked_groups:
                for question in group:
                    used_question_ids.add(question.id)
            part_selected_groups.extend(picked_groups)

        part_selected_groups.sort(key=lambda group: (group[0].id, group[0].question_order))
        for group in part_selected_groups:
            selected.extend(group)

    return selected


def delete_question_dependencies(db: Session, question_id: int) -> None:
    db.query(TestAttemptAnswer).filter(
        TestAttemptAnswer.question_id == question_id
    ).delete(synchronize_session=False)
    db.query(UserBookmark).filter(
        UserBookmark.question_id == question_id
    ).delete(synchronize_session=False)


@router.get("")
def list_questions(
    part: int | None = Query(default=None),
    approval_status: str | None = Query(default=None),
    random_mode: bool = Query(default=False),
    limit: int = Query(default=50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role in {"admin", "teacher", "moderator"}:
        query = db.query(Question).outerjoin(
            QuestionWorkflow,
            QuestionWorkflow.question_id == Question.id,
        )
        if approval_status is not None:
            normalized_status = normalize_approval_status(approval_status)
            query = query.filter(
                (QuestionWorkflow.approval_status == normalized_status)
                | (
                    QuestionWorkflow.approval_status.is_(None)
                    & (Question.approval_status == normalized_status)
                )
            )
    else:
        query = get_approved_questions_query(db)

    if part is not None:
        query = query.filter(Question.part == part)

    questions = query.order_by(Question.id.desc()).all()

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
        target_count = MINI_TEST_PART_QUESTION_COUNT.get(part)
        if target_count is None:
            raise HTTPException(status_code=400, detail="Part không hợp lệ cho mini test.")

        selected = select_structured_questions_for_part(
            db,
            part=part,
            target_question_count=target_count,
        )

        return {
            "test_type": "mini",
            "part": part,
            "total_questions": len(selected),
            "questions": [serialize_question_public(q) for q in selected],
        }

    selected = []

    for p, count in MINI_TEST_DISTRIBUTION.items():
        part_questions = get_approved_questions_query(db, part=p).all()

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
    require_premium_feature(current_user, "Full test")
    selected = generate_full_test_by_difficulty(db)

    return {
        "test_type": "full",
        "total_questions": len(selected),
        "difficulty_mix": FULL_TEST_DIFFICULTY_DISTRIBUTION,
        "sections": [
            {"key": "listening", "title": "Bài nghe", "parts": [1, 2, 3, 4]},
            {"key": "reading", "title": "Bài đọc", "parts": [5, 6, 7]},
        ],
        "questions": [serialize_question_public(q) for q in selected],
    }


@router.post("/generate")
def generate_test(
    payload: GeneratedTestRequest,
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    avoid_question_ids = set(payload.avoid_question_ids)

    if payload.test_type == "mini":
        if payload.part is None:
            raise HTTPException(status_code=400, detail="part is required for mini test generation")

        selected = select_structured_questions_for_part(
            db,
            part=payload.part,
            target_question_count=MINI_TEST_PART_QUESTION_COUNT.get(payload.part, 10),
        )
        selected = [question for question in selected if question.id not in avoid_question_ids]
        return {
            "generated_by": staff.id,
            "test_type": "mini",
            "part": payload.part,
            "total_questions": len(selected),
            "questions": [serialize_question_public(q) for q in selected],
        }

    selected = generate_full_test_by_difficulty(
        db,
        avoid_question_ids=avoid_question_ids,
    )
    return {
        "generated_by": staff.id,
        "test_type": "full",
        "total_questions": len(selected),
        "difficulty_mix": FULL_TEST_DIFFICULTY_DISTRIBUTION,
        "questions": [serialize_question_public(q) for q in selected],
    }


@router.get("/published-tests")
def list_published_tests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    require_premium_feature(current_user, "Kho đề đã phát hành")
    tests = (
        db.query(PublishedTest)
        .filter(PublishedTest.status == "published")
        .order_by(PublishedTest.published_at.desc(), PublishedTest.id.desc())
        .all()
    )
    return [serialize_published_test_summary(test) for test in tests]


@router.get("/published-tests/{published_test_id}")
def get_published_test_detail(
    published_test_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    require_premium_feature(current_user, "Kho đề đã phát hành")
    published_test = (
        db.query(PublishedTest)
        .filter(PublishedTest.id == published_test_id, PublishedTest.status == "published")
        .first()
    )
    if not published_test:
        raise HTTPException(status_code=404, detail="Không tìm thấy đề đã phát hành.")

    questions = get_published_test_questions(db, published_test.id)
    return {
        **serialize_published_test_summary(published_test),
        "questions": [serialize_question_public(question) for question in questions],
    }


@router.post("/submit")
def submit_questions(
    payload: SubmitQuestionsRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not payload.answers:
        raise HTTPException(status_code=400, detail="Danh sách đáp án không được để trống.")
    if payload.test_type not in {"mini", "full", "custom"}:
        raise HTTPException(status_code=400, detail="Loại đề không hợp lệ.")

    question_ids = [item.question_id for item in payload.answers]

    if len(question_ids) != len(set(question_ids)):
        raise HTTPException(status_code=400, detail="Danh sách đáp án đang bị trùng câu hỏi.")

    questions = db.query(Question).filter(Question.id.in_(question_ids)).all()
    question_map = {q.id: q for q in questions}

    if len(question_map) != len(question_ids):
        raise HTTPException(status_code=400, detail="Có câu hỏi không hợp lệ trong danh sách.")

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
                "section": q.section or infer_section_from_part(q.part),
                "group_key": q.group_key,
                "question_order": q.question_order,
                "instructions": q.instructions,
                "shared_content": q.shared_content,
                "shared_audio_url": q.shared_audio_url,
                "shared_image_url": q.shared_image_url,
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


def build_attempt_detail_response(attempt: TestAttempt, db: Session):
    attempt = (
        db.query(TestAttempt)
        .filter(TestAttempt.id == attempt.id)
        .first()
    ) or attempt

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
                "section": question.section or infer_section_from_part(question.part),
                "group_key": question.group_key,
                "question_order": question.question_order,
                "instructions": question.instructions,
                "shared_content": question.shared_content,
                "shared_audio_url": question.shared_audio_url,
                "shared_image_url": question.shared_image_url,
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
        raise HTTPException(status_code=404, detail="Không tìm thấy bài làm.")

    return build_attempt_detail_response(attempt, db)


@router.post("/{question_id}/bookmark")
def bookmark_question(
    question_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    question = db.query(Question).filter(Question.id == question_id).first()

    if not question:
        raise HTTPException(status_code=404, detail="Không tìm thấy câu hỏi.")

    existing = db.query(UserBookmark).filter(
        UserBookmark.user_id == current_user.id,
        UserBookmark.question_id == question_id,
    ).first()

    if existing:
        return {"message": "Câu hỏi này đã được lưu trước đó."}

    bookmark = UserBookmark(user_id=current_user.id, question_id=question_id)
    db.add(bookmark)
    db.commit()

    return {"message": "Đã lưu câu hỏi thành công."}


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
        raise HTTPException(status_code=404, detail="Không tìm thấy mục đã lưu.")

    db.delete(bookmark)
    db.commit()

    return {"message": "Đã bỏ lưu câu hỏi thành công."}


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
    staff: User = Depends(require_staff),
):
    source_hash = build_question_source_hash(
        part=payload.part,
        group_key=payload.group_key,
        content=payload.content,
        option_a=payload.option_a,
        option_b=payload.option_b,
        option_c=payload.option_c,
        option_d=payload.option_d,
    )
    ensure_question_not_duplicate(db, source_hash=source_hash)

    approval_status = "pending" if staff.role == "teacher" else "approved"
    question_group = ensure_question_group(
        db,
        part=payload.part,
        section=payload.section or infer_section_from_part(payload.part),
        group_key=payload.group_key,
        instructions=payload.instructions,
        shared_content=payload.shared_content,
        shared_audio_url=payload.shared_audio_url,
        shared_image_url=payload.shared_image_url,
    )
    question = Question(
        part=payload.part,
        section=payload.section or infer_section_from_part(payload.part),
        question_group_id=question_group.id if question_group else None,
        difficulty=normalize_difficulty(payload.difficulty),
        approval_status=approval_status,
        group_key=payload.group_key,
        question_order=payload.question_order,
        instructions=payload.instructions,
        shared_content=payload.shared_content,
        shared_audio_url=payload.shared_audio_url,
        shared_image_url=payload.shared_image_url,
        content=payload.content,
        option_a=payload.option_a,
        option_b=payload.option_b,
        option_c=payload.option_c,
        option_d=payload.option_d,
        correct_answer=payload.correct_answer,
        explanation=payload.explanation,
        audio_url=payload.audio_url,
        image_url=payload.image_url,
        source_hash=source_hash,
        submitted_by=staff.id,
        approved_by=staff.id if approval_status == "approved" else None,
    )
    db.add(question)
    db.flush()
    ensure_question_workflow(
        db,
        question=question,
        difficulty=normalize_difficulty(payload.difficulty),
        approval_status=approval_status,
        review_note=None,
        source_hash=source_hash,
        submitted_by=staff.id,
        approved_by=staff.id if approval_status == "approved" else None,
    )
    db.commit()
    db.refresh(question)

    return {
        "message": "Đã gửi câu hỏi lên chờ duyệt." if approval_status == "pending" else "Tạo câu hỏi thành công.",
        "id": question.id,
        "approval_status": question.approval_status,
    }


@router.post("/upload")
def upload_question_media(
    file: UploadFile = File(...),
    admin: User = Depends(require_admin),
):
    ext = os.path.splitext(file.filename)[1].lower()
    allowed = [".mp3", ".wav", ".ogg", ".jpg", ".jpeg", ".png", ".webp"]

    if ext not in allowed:
        raise HTTPException(status_code=400, detail="Loại tệp tải lên không được hỗ trợ.")

    filename = f"{uuid.uuid4().hex}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return {
        "message": "Tải tệp lên thành công.",
        "file_url": f"/uploads/{filename}",
    }


@router.put("/{question_id}")
def update_question(
    question_id: int,
    payload: QuestionUpdate,
    db: Session = Depends(get_db),
    staff: User = Depends(require_staff),
):
    question = db.query(Question).filter(Question.id == question_id).first()

    if not question:
        raise HTTPException(status_code=404, detail="Không tìm thấy câu hỏi.")

    update_data = payload.dict(exclude_unset=True)
    future_values = {
        "part": update_data.get("part", question.part),
        "group_key": update_data.get("group_key", get_question_group_key(question)),
        "content": update_data.get("content", question.content),
        "option_a": update_data.get("option_a", question.option_a),
        "option_b": update_data.get("option_b", question.option_b),
        "option_c": update_data.get("option_c", question.option_c),
        "option_d": update_data.get("option_d", question.option_d),
    }
    source_hash = build_question_source_hash(**future_values)
    ensure_question_not_duplicate(db, source_hash=source_hash, exclude_question_id=question.id)

    for key, value in update_data.items():
        if key == "difficulty" and value is not None:
            value = normalize_difficulty(value)
        if key == "approval_status" and value is not None:
            value = normalize_approval_status(value)
        setattr(question, key, value)

    question_group = ensure_question_group(
        db,
        part=update_data.get("part", question.part),
        section=update_data.get("section", question.section),
        group_key=update_data.get("group_key", get_question_group_key(question)),
        instructions=update_data.get("instructions", get_question_instructions(question)),
        shared_content=update_data.get("shared_content", get_question_shared_content(question)),
        shared_audio_url=update_data.get("shared_audio_url", get_question_shared_audio_url(question)),
        shared_image_url=update_data.get("shared_image_url", get_question_shared_image_url(question)),
    )
    question.question_group_id = question_group.id if question_group else None
    question.source_hash = source_hash
    if staff.role == "teacher":
        question.approval_status = "pending"
        question.approved_by = None

    ensure_question_workflow(
        db,
        question=question,
        difficulty=normalize_difficulty(update_data.get("difficulty", get_question_difficulty(question))),
        approval_status=question.approval_status,
        review_note=get_question_review_note(question),
        source_hash=source_hash,
        submitted_by=get_question_submitted_by(question) or staff.id,
        approved_by=question.approved_by,
    )

    db.commit()
    db.refresh(question)

    return {
        "message": "Cập nhật câu hỏi thành công.",
        "id": question.id,
        "approval_status": question.approval_status,
    }


@router.put("/{question_id}/approval")
def update_question_approval(
    question_id: int,
    payload: QuestionApprovalPayload,
    db: Session = Depends(get_db),
    moderator: User = Depends(require_roles("admin", "moderator")),
):
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Không tìm thấy câu hỏi.")

    question.approval_status = normalize_approval_status(payload.approval_status)
    question.review_note = (payload.review_note or "").strip() or None
    question.approved_by = moderator.id if question.approval_status == "approved" else None
    ensure_question_workflow(
        db,
        question=question,
        difficulty=get_question_difficulty(question),
        approval_status=question.approval_status,
        review_note=question.review_note,
        source_hash=get_question_source_hash(question),
        submitted_by=get_question_submitted_by(question),
        approved_by=question.approved_by,
    )

    db.commit()
    db.refresh(question)

    return {
        "message": "Cập nhật trạng thái duyệt thành công.",
        "id": question.id,
        "approval_status": question.approval_status,
        "review_note": question.review_note,
    }


@router.delete("/{question_id}")
def delete_question(
    question_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    question = db.query(Question).filter(Question.id == question_id).first()

    if not question:
        raise HTTPException(status_code=404, detail="Không tìm thấy câu hỏi.")

    delete_question_dependencies(db, question_id)
    db.delete(question)
    db.commit()

    return {"message": "Xóa câu hỏi thành công."}
