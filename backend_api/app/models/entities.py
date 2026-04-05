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
    created_at = Column(DateTime, server_default=func.now())


class Question(Base):
    __tablename__ = "questions"

    id = Column(Integer, primary_key=True, index=True)
    part = Column(Integer, nullable=False, index=True)
    section = Column(String(20), nullable=True, index=True)
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
    created_at = Column(DateTime, server_default=func.now())


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
