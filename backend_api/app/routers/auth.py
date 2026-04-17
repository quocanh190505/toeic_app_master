from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.entities import PremiumPaymentRequest, RefreshToken, User, UserProgress
from app.schemas.auth import (
    ChangePasswordRequest,
    LoginRequest,
    PremiumPaymentRequestCreate,
    RefreshTokenRequest,
    RegisterRequest,
    TokenResponse,
    UpgradePremiumRequest,
)
from app.services.auth_service import (
    create_access_token,
    create_refresh_token,
    decode_refresh_token,
    hash_password,
    verify_password,
)

router = APIRouter(prefix="/auth", tags=["auth"])

PREMIUM_MONTH_PRICES = {
    1: 79000,
    3: 199000,
    12: 599000,
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


def revoke_user_refresh_tokens(db: Session, user_id: int) -> None:
    db.query(RefreshToken).filter(
        RefreshToken.user_id == user_id,
        RefreshToken.is_revoked == False,
    ).update(
        {"is_revoked": True},
        synchronize_session=False,
    )


def is_expired(expires_at: datetime) -> bool:
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    return expires_at < datetime.now(timezone.utc)


def serialize_payment_request(item: PremiumPaymentRequest) -> dict:
    return {
        "id": item.id,
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


@router.post("/register")
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing_user = db.query(User).filter(User.email == payload.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email đã tồn tại trong hệ thống.")

    new_user = User(
        full_name=payload.full_name,
        email=payload.email,
        password_hash=hash_password(payload.password),
        role="user",
        target_score=payload.target_score,
        membership_plan="basic",
    )
    db.add(new_user)
    db.flush()

    progress = db.query(UserProgress).filter(UserProgress.user_id == new_user.id).first()
    if not progress:
        progress = UserProgress(
            user_id=new_user.id,
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

    db.commit()
    db.refresh(new_user)

    return {
        "message": "Đăng ký thành công.",
        "user_id": new_user.id,
        "email": new_user.email,
        "role": new_user.role,
        "membership_plan": new_user.membership_plan,
    }


@router.post("/login", response_model=TokenResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Email hoặc mật khẩu không đúng.")

    access_token = create_access_token(str(user.id))
    refresh_token, expires_at = create_refresh_token(str(user.id))

    refresh_token_row = RefreshToken(
        user_id=user.id,
        token=refresh_token,
        expires_at=expires_at,
        is_revoked=False,
    )
    db.add(refresh_token_row)
    db.commit()

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "role": user.role,
    }


@router.post("/refresh", response_model=TokenResponse)
def refresh_token_api(payload: RefreshTokenRequest, db: Session = Depends(get_db)):
    token_row = db.query(RefreshToken).filter(RefreshToken.token == payload.refresh_token).first()
    if not token_row:
        raise HTTPException(status_code=401, detail="Phiên đăng nhập đã hết hạn.")
    if token_row.is_revoked:
        raise HTTPException(status_code=401, detail="Phiên đăng nhập đã bị thu hồi.")
    if is_expired(token_row.expires_at):
        raise HTTPException(status_code=401, detail="Phiên đăng nhập đã hết hạn.")

    decoded = decode_refresh_token(payload.refresh_token)
    user_id = decoded.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Phiên đăng nhập không hợp lệ.")

    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(status_code=401, detail="Không tìm thấy người dùng.")

    token_row.is_revoked = True

    new_access_token = create_access_token(str(user.id))
    new_refresh_token, expires_at = create_refresh_token(str(user.id))

    new_token_row = RefreshToken(
        user_id=user.id,
        token=new_refresh_token,
        expires_at=expires_at,
        is_revoked=False,
    )
    db.add(new_token_row)
    db.commit()

    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer",
        "role": user.role,
    }


@router.post("/change-password")
def change_password(
    payload: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not verify_password(payload.old_password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="Mật khẩu hiện tại không đúng.")

    current_user.password_hash = hash_password(payload.new_password)
    revoke_user_refresh_tokens(db, current_user.id)
    db.commit()

    return {"message": "Đổi mật khẩu thành công."}


@router.get("/me")
def me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    latest_payment = (
        db.query(PremiumPaymentRequest)
        .filter(PremiumPaymentRequest.user_id == current_user.id)
        .order_by(PremiumPaymentRequest.created_at.desc(), PremiumPaymentRequest.id.desc())
        .first()
    )

    return {
        "id": current_user.id,
        "full_name": current_user.full_name,
        "email": current_user.email,
        "role": current_user.role,
        "target_score": current_user.target_score,
        "membership_plan": current_user.membership_plan or "basic",
        "is_premium": is_user_premium_active(current_user),
        "premium_started_at": current_user.premium_started_at,
        "premium_expires_at": current_user.premium_expires_at,
        "premium_cancel_at_period_end": current_user.premium_cancel_at_period_end,
        "latest_premium_request": serialize_payment_request(latest_payment) if latest_payment else None,
    }


@router.post("/premium-payment-requests")
def create_premium_payment_request(
    payload: PremiumPaymentRequestCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    latest_pending = (
        db.query(PremiumPaymentRequest)
        .filter(
            PremiumPaymentRequest.user_id == current_user.id,
            PremiumPaymentRequest.status == "pending",
        )
        .first()
    )
    if latest_pending:
        raise HTTPException(
            status_code=400,
            detail="Bạn đang có một yêu cầu nâng cấp Premium chờ duyệt.",
        )

    amount = PREMIUM_MONTH_PRICES.get(payload.months, payload.months * 79000)
    request_row = PremiumPaymentRequest(
        user_id=current_user.id,
        months=payload.months,
        amount=amount,
        status="pending",
        transaction_code=(payload.transaction_code or "").strip() or None,
        note=(payload.note or "").strip() or None,
    )
    db.add(request_row)
    db.commit()
    db.refresh(request_row)

    return {
        "message": "Đã gửi yêu cầu nâng cấp Premium. Vui lòng chờ kiểm duyệt.",
        "request": serialize_payment_request(request_row),
    }


@router.get("/premium-payment-requests/me")
def list_my_premium_payment_requests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(PremiumPaymentRequest)
        .filter(PremiumPaymentRequest.user_id == current_user.id)
        .order_by(PremiumPaymentRequest.created_at.desc(), PremiumPaymentRequest.id.desc())
        .all()
    )
    return [serialize_payment_request(item) for item in rows]


@router.post("/upgrade-premium")
def upgrade_premium(
    payload: UpgradePremiumRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    raise HTTPException(
        status_code=400,
        detail="Hãy gửi yêu cầu thanh toán Premium và chờ kiểm duyệt duyệt.",
    )


@router.post("/cancel-premium")
def cancel_premium(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not is_user_premium_active(current_user):
        current_user.membership_plan = "basic"
        current_user.premium_started_at = None
        current_user.premium_expires_at = None
        current_user.premium_cancel_at_period_end = False
    else:
        current_user.premium_cancel_at_period_end = True
    db.commit()
    db.refresh(current_user)

    return {
        "message": (
            "Gói Premium sẽ được hủy khi hết chu kỳ hiện tại."
            if is_user_premium_active(current_user)
            else "Đã hủy gói Premium thành công."
        ),
        "membership_plan": current_user.membership_plan,
        "is_premium": is_user_premium_active(current_user),
        "premium_started_at": current_user.premium_started_at,
        "premium_expires_at": current_user.premium_expires_at,
        "premium_cancel_at_period_end": current_user.premium_cancel_at_period_end,
    }
