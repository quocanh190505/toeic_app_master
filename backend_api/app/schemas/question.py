from datetime import datetime
from typing import Optional, List, Literal
from pydantic import BaseModel


class QuestionCreate(BaseModel):
    part: int
    section: Optional[str] = None
    difficulty: Literal["easy", "medium", "hard"] = "medium"
    group_key: Optional[str] = None
    question_order: int = 1
    instructions: Optional[str] = None
    shared_content: Optional[str] = None
    shared_audio_url: Optional[str] = None
    shared_image_url: Optional[str] = None
    content: str
    option_a: str
    option_b: str
    option_c: str
    option_d: str
    correct_answer: Literal["A", "B", "C", "D"]
    explanation: Optional[str] = None
    audio_url: Optional[str] = None
    image_url: Optional[str] = None


class QuestionUpdate(BaseModel):
    part: Optional[int] = None
    section: Optional[str] = None
    difficulty: Optional[Literal["easy", "medium", "hard"]] = None
    approval_status: Optional[Literal["pending", "approved", "rejected"]] = None
    group_key: Optional[str] = None
    question_order: Optional[int] = None
    instructions: Optional[str] = None
    shared_content: Optional[str] = None
    shared_audio_url: Optional[str] = None
    shared_image_url: Optional[str] = None
    content: Optional[str] = None
    option_a: Optional[str] = None
    option_b: Optional[str] = None
    option_c: Optional[str] = None
    option_d: Optional[str] = None
    correct_answer: Optional[Literal["A", "B", "C", "D"]] = None
    explanation: Optional[str] = None
    audio_url: Optional[str] = None
    image_url: Optional[str] = None


class AnswerSubmitItem(BaseModel):
    question_id: int
    selected_answer: Optional[Literal["A", "B", "C", "D"]] = None


class SubmitQuestionsRequest(BaseModel):
    answers: List[AnswerSubmitItem]
    test_type: str = "custom"


class AttemptSummaryResponse(BaseModel):
    id: int
    test_type: str
    total_questions: int
    correct_count: int
    score: int
    submitted_at: datetime


class QuestionApprovalPayload(BaseModel):
    approval_status: Literal["approved", "rejected"]
    review_note: Optional[str] = None


class GeneratedTestRequest(BaseModel):
    test_type: Literal["mini", "full"] = "full"
    part: Optional[int] = None
    avoid_question_ids: List[int] = []


class PublishedTestCreateRequest(BaseModel):
    title: str
    description: Optional[str] = None
    test_type: Literal["mini", "full"] = "full"
    part: Optional[int] = None
    question_ids: List[int]
