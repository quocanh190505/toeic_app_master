# TOEIC Master Pro - Full Stack

Project gồm 3 phần:
- `flutter_app/`: ứng dụng Flutter mobile
- `backend_api/`: FastAPI backend
- `database/schema.sql`: MySQL schema và dữ liệu mẫu

## Tính năng đã dựng
- Đăng nhập
- Dashboard đẹp, hiện đại
- Lưu tiến độ học
- Mock test demo
- Audio streaming cho Listening
- Backend REST API
- MySQL schema cứng để lưu users, questions, progress

## 1) Chạy backend API
```bash
cd backend_api
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## 2) Import MySQL database
```bash
mysql -u root -p < database/schema.sql
```

Sửa chuỗi kết nối trong:
- `backend_api/app/core/config.py`

## 3) Chạy Flutter app
```bash
cd flutter_app
flutter pub get
flutter run
```

## Gợi ý nâng cấp tiếp theo
- JWT refresh token thật
- Admin CMS quản lý đề TOEIC
- Upload audio lên S3/Cloud Storage
- Random đề 200 câu đầy đủ
- Chấm band Listening/Reading chuẩn TOEIC
- Phân tích điểm yếu theo Part
