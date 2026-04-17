from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey, Text, Boolean, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship  # THÊM DÒNG NÀY ĐỂ TẠO LIÊN KẾT GIỮA CÁC BẢNG

from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), nullable=False, default="user", server_default="user", index=True)
    target_score = Column(Integer, default=750)
    membership_plan = Column(String(20), nullable=False, default="basic", server_default="basic", index=True)
    premium_started_at = Column(DateTime, nullable=True)
    premium_expires_at = Column(DateTime, nullable=True, index=True)
    premium_cancel_at_period_end = Column(Boolean, nullable=False, default=False, server_default="0")
    created_at = Column(DateTime, server_default=func.now())

    premium_payment_requests = relationship(
        "PremiumPaymentRequest",
        back_populates="user",
        foreign_keys="PremiumPaymentRequest.user_id",
    )


class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    part = Column(Integer, nullable=False, index=True)
    section = Column(String(20), nullable=True, index=True)
    question_group_id = Column(Integer, ForeignKey("question_groups.id"), nullable=True, index=True)
    difficulty = Column(String(20), nullable=False, default="medium", server_default="medium", index=True)
    approval_status = Column(String(20), nullable=False, default="approved", server_default="approved", index=True)
    group_key = Column(String(100), nullable=True, index=True)
    question_order = Column(Integer, nullable=False, default=1, server_default="1")
    instructions = Column(Text, nullable=True)
    shared_content = Column(Text, nullable=True)
    shared_audio_url = Column(String(500), nullable=True)
    shared_image_url = Column(String(500), nullable=True)
    content = Column(Text, nullable=False)
    option_a = Column(String(255), nullable=False)
    option_b = Column(String(255), nullable=False)
    option_c = Column(String(255), nullable=False)
    option_d = Column(String(255), nullable=False)
    correct_answer = Column(String(10), nullable=False)
    explanation = Column(Text, nullable=True)
    audio_url = Column(String(500), nullable=True)
    image_url = Column(String(500), nullable=True)
    review_note = Column(Text, nullable=True)
    source_hash = Column(String(64), nullable=True, unique=True, index=True)
    submitted_by = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    approved_by = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    created_at = Column(DateTime, server_default=func.now())

    question_group = relationship("QuestionGroup", back_populates="questions")
    workflow = relationship("QuestionWorkflow", back_populates="question", uselist=False)


class QuestionGroup(Base):
    __tablename__ = "question_groups"

    id = Column(Integer, primary_key=True, index=True)
    group_key = Column(String(100), nullable=False, unique=True, index=True)
    part = Column(Integer, nullable=False, index=True)
    section = Column(String(20), nullable=True, index=True)
    instructions = Column(Text, nullable=True)
    shared_content = Column(Text, nullable=True)
    shared_audio_url = Column(String(500), nullable=True)
    shared_image_url = Column(String(500), nullable=True)
    created_at = Column(DateTime, server_default=func.now())

    questions = relationship("Question", back_populates="question_group")


class QuestionWorkflow(Base):
    __tablename__ = "question_workflows"
    __table_args__ = (
        UniqueConstraint("question_id", name="uq_question_workflows_question"),
        UniqueConstraint("source_hash", name="uq_question_workflows_source_hash"),
    )

    id = Column(Integer, primary_key=True, index=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False, index=True)
    difficulty = Column(String(20), nullable=False, default="medium", server_default="medium", index=True)
    approval_status = Column(String(20), nullable=False, default="approved", server_default="approved", index=True)
    review_note = Column(Text, nullable=True)
    source_hash = Column(String(64), nullable=True, index=True)
    submitted_by = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    approved_by = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    submitted_at = Column(DateTime, server_default=func.now(), index=True)
    reviewed_at = Column(DateTime, nullable=True)

    question = relationship("Question", back_populates="workflow")


class UserProgress(Base):
    __tablename__ = "user_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    studied_words = Column(Integer, default=0)
    completed_tests = Column(Integer, default=0)
    current_streak = Column(Integer, default=0)
    overall_progress = Column(Float, default=0.0)

    total_questions_answered = Column(Integer, default=0)
    total_correct_answers = Column(Integer, default=0)
    highest_score = Column(Integer, default=0)
    average_score = Column(Float, default=0.0)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())


class TestAttempt(Base):
    __tablename__ = "test_attempts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    test_type = Column(String(20), nullable=False, default="mini")  # mini | full | custom
    total_questions = Column(Integer, nullable=False)
    correct_count = Column(Integer, nullable=False, default=0)
    score = Column(Integer, nullable=False, default=0)
    submitted_at = Column(DateTime, server_default=func.now(), index=True)


class PublishedTest(Base):
    __tablename__ = "published_tests"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    test_type = Column(String(20), nullable=False, default="full", index=True)
    part = Column(Integer, nullable=True, index=True)
    status = Column(String(20), nullable=False, default="published", server_default="published", index=True)
    total_questions = Column(Integer, nullable=False, default=0)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    published_at = Column(DateTime, server_default=func.now(), index=True)

    items = relationship(
        "PublishedTestItem",
        back_populates="published_test",
        cascade="all, delete-orphan",
    )


class PublishedTestItem(Base):
    __tablename__ = "published_test_items"
    __table_args__ = (
        UniqueConstraint("published_test_id", "question_id", name="uq_published_test_question"),
        UniqueConstraint("published_test_id", "display_order", name="uq_published_test_order"),
    )

    id = Column(Integer, primary_key=True, index=True)
    published_test_id = Column(Integer, ForeignKey("published_tests.id"), nullable=False, index=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False, index=True)
    display_order = Column(Integer, nullable=False, default=1)

    published_test = relationship("PublishedTest", back_populates="items")
    question = relationship("Question")


class TestAttemptAnswer(Base):
    __tablename__ = "test_attempt_answers"
    __table_args__ = (
        UniqueConstraint("attempt_id", "question_id", name="uq_attempt_question"),
    )

    id = Column(Integer, primary_key=True, index=True)
    attempt_id = Column(Integer, ForeignKey("test_attempts.id"), nullable=False, index=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False, index=True)
    selected_answer = Column(String(10), nullable=True)
    correct_answer = Column(String(10), nullable=False)
    is_correct = Column(Boolean, default=False)
    part = Column(Integer, nullable=False)


class UserBookmark(Base):
    __tablename__ = "user_bookmarks"
    __table_args__ = (
        UniqueConstraint("user_id", "question_id", name="uq_user_bookmark_question"),
    )

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False, index=True)
    created_at = Column(DateTime, server_default=func.now())


# --- THÊM CLASS TOPIC MỚI ---
class Topic(Base):
    __tablename__ = "topics"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(500), nullable=True)

    words = relationship("VocabularyWord", back_populates="topic")


class VocabularyWord(Base):
    __tablename__ = "vocabulary_words"

    id = Column(Integer, primary_key=True, index=True)
    word = Column(String(255), nullable=False, unique=True, index=True)
    meaning = Column(Text, nullable=False)
    example = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    
    # --- THÊM 2 DÒNG NÀY ĐỂ LIÊN KẾT VỚI BẢNG TOPICS ---
    topic_id = Column(Integer, ForeignKey("topics.id"), nullable=True)
    topic = relationship("Topic", back_populates="words")


class UserStudiedWord(Base):
    __tablename__ = "user_studied_words"
    __table_args__ = (
        UniqueConstraint("user_id", "word_id", name="uq_user_word"),
    )

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    word_id = Column(Integer, ForeignKey("vocabulary_words.id"), nullable=False, index=True)
    studied_at = Column(DateTime, server_default=func.now())


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    token = Column(String(1000), nullable=False, unique=True, index=True)
    is_revoked = Column(Boolean, default=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, server_default=func.now())


class PremiumPaymentRequest(Base):
    __tablename__ = "premium_payment_requests"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    months = Column(Integer, nullable=False)
    amount = Column(Integer, nullable=False)
    status = Column(String(20), nullable=False, default="pending", server_default="pending", index=True)
    transaction_code = Column(String(100), nullable=True, index=True)
    note = Column(Text, nullable=True)
    review_note = Column(Text, nullable=True)
    reviewed_by = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    created_at = Column(DateTime, server_default=func.now(), index=True)
    reviewed_at = Column(DateTime, nullable=True)

    user = relationship("User", foreign_keys=[user_id], back_populates="premium_payment_requests")
