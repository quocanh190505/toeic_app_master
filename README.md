# TOEIC Master Pro

Đây là project luyện thi TOEIC full-stack gồm backend FastAPI, app Flutter và dữ liệu MySQL mẫu.

## Cấu trúc thư mục

```text
toeic_fullstack_project/
|- backend_api/      # Backend FastAPI + SQLAlchemy
|- database/         # File SQL tạo bảng và seed dữ liệu
|- flutter_app/      # Ứng dụng Flutter chính
|- flutter/          # Flutter SDK/source local trên máy này
`- README.md
```

Lưu ý:
- `flutter_app/` mới là app bạn cần mở để code.
- `flutter/` trong repo này là mã nguồn Flutter SDK cục bộ, không phải app chính.

## Công nghệ sử dụng

- Backend: FastAPI, SQLAlchemy, MySQL
- Frontend mobile: Flutter
- Auth: JWT access token + refresh token

## Tính năng chính

- Đăng ký, đăng nhập
- Luyện mini test và full test TOEIC
- Tự chấm điểm, xem lịch sử làm bài
- Học từ vựng theo chủ đề
- Quản lý người dùng, chủ đề, từ vựng, câu hỏi cho admin

## Yêu cầu môi trường

- Python 3.11 trở lên
- MySQL 8 trở lên
- Flutter SDK
- Android Studio hoặc VS Code
- Android Emulator hoặc điện thoại Android

## Clone project

```bash
git clone <repository-url>
cd toeic_fullstack_project
```

## Cài database

Tạo database trước:

```sql
CREATE DATABASE toeic_master CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Sau đó import file SQL:

```bash
mysql -u root -p < database/schema.sql
```

Nếu bạn chỉ muốn nạp lại riêng dữ liệu câu hỏi cho bảng `questions`, có thể dùng:

- [database/seed_questions_only.sql](/d:/pythontest/toeic_fullstack_project/database/seed_questions_only.sql)

## Tài khoản mẫu sau khi import `schema.sql`

- Admin
  - Email: `admin@toeic.com`
  - Mật khẩu: `123456`
- User
  - Email: `student@toeic.com`
  - Mật khẩu: `123456`

## Chạy backend

Mở terminal tại `backend_api/`:

```bash
cd backend_api
python -m venv .venv
```

PowerShell:

```powershell
.venv\Scripts\Activate.ps1
```

Cài thư viện:

```bash
pip install -r requirements.txt
```

Chạy API:

```bash
uvicorn app.main:app --reload
```

Backend mặc định chạy ở:

- `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`

### Cấu hình backend bằng `.env`

Để người khác clone về chạy dễ hơn, backend đã có sẵn file mẫu:

- [backend_api/.env.example](/d:/pythontest/toeic_fullstack_project/backend_api/.env.example)

Sau khi clone project, làm như sau trong thư mục `backend_api/`:

1. copy `.env.example` thành `.env`
2. sửa lại giá trị cho đúng máy đang dùng

Ví dụ:

```env
MYSQL_URL=mysql+pymysql://toeic_user:your_password@localhost:3306/toeic_master
JWT_SECRET=your_super_secret_key_here
```

Nếu máy bạn đang chạy được bằng cấu hình mặc định cũ thì vẫn có thể dùng như cũ, nhưng khi bàn giao cho người khác nên dùng `.env`.

## Chạy Flutter app

Mở terminal mới:

```bash
cd flutter_app
flutter pub get
flutter run
```

Hiện tại app đang để:

- `baseUrl = http://10.0.2.2:8000`

Cấu hình này phù hợp khi chạy bằng Android emulator và backend chạy local trên máy.

File cấu hình API:

- [flutter_app/lib/core/constants/api_constants.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/core/constants/api_constants.dart)

## Cách chạy nhanh toàn project

### Terminal 1

```bash
cd backend_api
.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload
```

### Terminal 2

```bash
cd flutter_app
flutter pub get
flutter run
```

## Test

Trong `flutter_app/`:

```bash
flutter test
flutter test integration_test
```

## Một số file quan trọng

### Backend

- [backend_api/app/main.py](/d:/pythontest/toeic_fullstack_project/backend_api/app/main.py)
- [backend_api/app/core/config.py](/d:/pythontest/toeic_fullstack_project/backend_api/app/core/config.py)
- [backend_api/app/models/entities.py](/d:/pythontest/toeic_fullstack_project/backend_api/app/models/entities.py)
- [backend_api/app/routers/auth.py](/d:/pythontest/toeic_fullstack_project/backend_api/app/routers/auth.py)
- [backend_api/app/routers/admin.py](/d:/pythontest/toeic_fullstack_project/backend_api/app/routers/admin.py)
- [backend_api/app/routers/questions.py](/d:/pythontest/toeic_fullstack_project/backend_api/app/routers/questions.py)

### Flutter

- [flutter_app/lib/main.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/main.dart)
- [flutter_app/lib/core/constants/api_constants.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/core/constants/api_constants.dart)
- [flutter_app/lib/services/](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/services)
- [flutter_app/lib/screens/auth/](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/auth)
- [flutter_app/lib/screens/home/](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/home)
- [flutter_app/lib/screens/admin/](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/admin)
- [flutter_app/lib/screens/practice/](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/practice)

## Lưu ý

- Nếu thư mục `flutter/` bị bôi đỏ trong IDE thì thường không ảnh hưởng đến app chính. Bạn nên tập trung làm việc trong `flutter_app/`.
- Nếu tiếng Việt bị lỗi dấu, hãy lưu file bằng `UTF-8`.
- Nếu app không gọi được backend, hãy kiểm tra backend có đang chạy không và `baseUrl` có đúng không.
- Nếu dùng điện thoại thật thay vì emulator, `10.0.2.2` sẽ không còn phù hợp. Khi đó cần đổi `baseUrl`.

## Ghi chú hiện trạng project

Project hiện đã được chỉnh thêm:

- fix nhiều lỗi backend liên quan đến xóa dữ liệu và refresh token
- thêm seed dữ liệu đủ 200 câu cho full test
- cải thiện giao diện login, register, home, admin
- thêm đồng hồ đếm ngược và tự nộp bài cho full test

Nếu bạn bàn giao cho người khác, chỉ cần bảo họ làm theo thứ tự:

1. import `database/schema.sql`
2. chạy backend
3. chạy `flutter_app`
4. đăng nhập bằng tài khoản mẫu để test
