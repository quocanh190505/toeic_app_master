from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.entities import User, Topic

router = APIRouter(prefix="/topics", tags=["topics"])

@router.get("")
def list_topics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    topics = db.query(Topic).all()
    return [
        {
            "id": t.id,
            "name": t.name,
            "description": t.description,
            "image_url": t.image_url
        }
        for t in topics
    ]