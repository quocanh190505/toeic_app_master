from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from app.routers import auth, progress, questions, admin, vocabulary, stats

app = FastAPI(title="TOEIC Master Pro API")

# Tạo thư mục uploads nếu chưa có
UPLOADS_DIR = Path("uploads")
UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
(UPLOADS_DIR / "audio").mkdir(parents=True, exist_ok=True)
(UPLOADS_DIR / "images").mkdir(parents=True, exist_ok=True)

# Mount static files để truy cập file đã upload
app.mount("/uploads", StaticFiles(directory=str(UPLOADS_DIR)), name="uploads")

app.include_router(auth.router)
app.include_router(progress.router)
app.include_router(questions.router)
app.include_router(admin.router)
app.include_router(vocabulary.router)
app.include_router(stats.router)


@app.get("/")
def root():
    return {"message": "TOEIC Master Pro API is running"}