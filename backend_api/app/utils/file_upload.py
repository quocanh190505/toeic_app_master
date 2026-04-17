import os
import uuid
from pathlib import Path
from fastapi import UploadFile, HTTPException

BASE_UPLOAD_DIR = Path("uploads")
IMAGE_UPLOAD_DIR = BASE_UPLOAD_DIR / "images"
AUDIO_UPLOAD_DIR = BASE_UPLOAD_DIR / "audio"

IMAGE_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
AUDIO_UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


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
