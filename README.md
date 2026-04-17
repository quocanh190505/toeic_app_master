# TOEIC Master Pro

Ứng dụng luyện thi TOEIC full-stack gồm:
- `backend_api`: FastAPI + SQLAlchemy + MySQL
- `flutter_app`: ứng dụng Flutter cho học viên, giáo viên, kiểm duyệt viên và quản trị viên
- `database`: schema, migration và file mẫu import

README này viết theo hướng bàn giao để người khác có thể:
- kéo code về máy
- cài môi trường
- chạy backend và Flutter
- chạy các migration cần thiết
- hiểu nhanh các vai trò và chức năng chính

## 1. Tính năng chính

### Học viên
- Đăng ký, đăng nhập, đổi mật khẩu
- Làm mini test và full test
- Xem lịch sử làm bài, tiến độ học tập, bảng xếp hạng
- Học từ vựng theo chủ đề
- Xem kho đề đã phát hành
- Nâng cấp Premium bằng luồng gửi yêu cầu thanh toán chờ duyệt

### Giáo viên
- Tạo câu hỏi thủ công
- Import câu hỏi từ `Word / PDF / JSON`
- Xem trước câu hỏi trước khi nộp
- Nộp câu hỏi lên hàng chờ duyệt
- Chỉ xem và sửa câu hỏi của chính mình

### Kiểm duyệt viên
- Duyệt hoặc từ chối câu hỏi
- Xem các yêu cầu nâng cấp Premium
- Duyệt hoặc từ chối yêu cầu Premium
- Sinh đề tự động

### Quản trị viên
- Toàn quyền như kiểm duyệt viên
- Quản lý người dùng và vai trò
- Quản lý câu hỏi, chủ đề, từ vựng
- Xem bài làm người dùng
- Phát hành đề cho học viên

## 2. Cấu trúc thư mục

```text
toeic_app_master/
|-- backend_api/
|-- database/
|-- flutter_app/
|-- flutter/              # Flutter SDK local trong repo (nếu có)
|-- .gitignore
`-- README.md
```

Lưu ý:
- `flutter_app/` là source app.
- `flutter/` là SDK Flutter local. Không bắt buộc phải commit/pull nếu máy đã có Flutter riêng.

## 3. Clone hoặc pull code

### Nếu chưa có project

```powershell
git clone <URL_REPO>
cd toeic_app_master
```

### Nếu đã có project từ trước

```powershell
cd D:\pythontest\toeic_test\toeic_app_master
git pull origin main
```

### Nếu muốn commit thay đổi

```powershell
git add .
git commit -m "Cap nhat project"
git push origin main
```

Lưu ý:
- Lệnh đúng là `git add .`
- Không phải `git add.`

## 4. Yêu cầu môi trường

### Backend
- Python 3.11+ hoặc tương đương
- MySQL

### Flutter
- Flutter SDK
- Android Studio hoặc emulator Android

### Công cụ DB khuyến nghị
- DataGrip, MySQL Workbench hoặc phpMyAdmin

## 5. Tạo database

Tạo database:

```sql
CREATE DATABASE toeic_master CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Import schema gốc:

```powershell
mysql -u root -p toeic_master < database/schema.sql
```

Nếu dùng DataGrip:
- mở `database/schema.sql`
- chọn datasource `toeic_master`
- bấm `Run`

## 6. Các migration cần chạy

Sau khi import `schema.sql`, chạy tiếp các migration sau theo đúng thứ tự:

1. `database/migrate_question_workflow.sql`
2. `database/migrate_question_normalization.sql`
3. `database/backfill_question_normalization.sql`
4. `database/migrate_published_tests.sql`
5. `database/migrate_premium_membership.sql`
6. `database/migrate_premium_cancellation.sql`
7. `database/migrate_premium_payment_requests.sql`

Nếu dùng DataGrip:
- mở từng file SQL
- chọn đúng datasource `toeic_master`
- bấm `Run`

## 7. Cấu hình backend

Vào thư mục backend:

```powershell
cd backend_api
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Tạo file `backend_api/.env`:

```env
MYSQL_URL=mysql+pymysql://root:19052005@localhost:3306/toeic_master?charset=utf8mb4
JWT_SECRET=toeic_master_secret_19052005
```

Bạn có thể thay `root:19052005` bằng tài khoản MySQL của máy mình.

## 8. Chạy backend

```powershell
cd backend_api
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload
```

Kiểm tra:
- API: `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`

## 9. Chạy Flutter app

Nếu máy đã cài Flutter trong PATH:

```powershell
cd flutter_app
flutter pub get
flutter run
```

Nếu dùng SDK Flutter nằm trong repo:

```powershell
cd flutter_app
..\flutter\bin\flutter.bat pub get
..\flutter\bin\flutter.bat run
```

Lưu ý:
- Android emulator truy cập backend local qua `http://10.0.2.2:8000`
- Cấu hình này đang nằm trong `flutter_app/lib/core/constants/api_constants.dart`

## 10. Các vai trò trong hệ thống

- `user`: học viên
- `teacher`: giáo viên nhập câu hỏi
- `moderator`: kiểm duyệt viên
- `admin`: quản trị viên

Cập nhật role nhanh trong SQL:

```sql
UPDATE users SET role = 'teacher' WHERE email = 'teacher@example.com';
UPDATE users SET role = 'moderator' WHERE email = 'moderator@example.com';
UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
```

## 11. Luồng import câu hỏi

### Cách 1: tạo thủ công
- đăng nhập bằng `teacher`
- vào màn tạo câu hỏi
- nhập nội dung và nộp

### Cách 2: import Word / PDF / JSON
- vào màn import
- chọn file
- bấm xem trước
- kiểm tra danh sách câu hỏi parse được
- bấm nộp lên chờ duyệt

### Định dạng Word/PDF khuyến nghị

Mỗi câu hỏi là một block, ngăn cách bằng:

```text
===
```

Ví dụ:

```text
PART: 5
DIFFICULTY: easy
QUESTION: The meeting will start at 9 A.M.
A: starts
B: start
C: started
D: starting
ANSWER: B
EXPLANATION: Sau will dùng động từ nguyên mẫu.
===
PART: 5
DIFFICULTY: medium
QUESTION: The new software allows employees to work ---- from any location.
A: remote
B: remotely
C: remoteness
D: remoter
ANSWER: B
```

File mẫu:
- `database/question_import_template.txt`

## 12. Luồng kiểm duyệt câu hỏi

1. `teacher` tạo hoặc import câu hỏi
2. câu hỏi vào trạng thái `pending`
3. `moderator` vào màn quản lý câu hỏi
4. lọc `pending`
5. duyệt `approved` hoặc từ chối `rejected`

## 13. Luồng sinh đề và phát hành đề

1. `moderator` hoặc `admin` sinh đề tự động
2. hệ thống chọn câu theo part và độ khó
3. có thể lưu thành đề phát hành
4. học viên thấy đề trong kho đề đã phát hành

## 14. Luồng Premium

### Giá hiện tại
- 1 tháng: `79.000đ`
- 3 tháng: `199.000đ`
- 12 tháng: `599.000đ`

### Luồng sử dụng
1. học viên vào tab `Tôi`
2. bấm `Đăng ký tài khoản Premium`
3. chọn gói
4. app hiển thị QR động theo đúng số tiền gói đã chọn
5. học viên chuyển khoản
6. học viên gửi yêu cầu Premium
7. `moderator` hoặc `admin` duyệt
8. tài khoản được nâng lên Premium sau khi duyệt

### Thông tin tài khoản hiện tại
- Ngân hàng: `MB Bank`
- Số tài khoản: `0123419052005`
- Chủ tài khoản: `DOAN QUOC ANH`

## 15. Các bảng dữ liệu chính

- `users`
- `questions`
- `question_groups`
- `question_workflows`
- `published_tests`
- `published_test_items`
- `premium_payment_requests`
- `user_progress`
- `test_attempts`
- `test_attempt_answers`
- `topics`
- `vocabulary_words`
- `user_bookmarks`
- `user_studied_words`
- `refresh_tokens`

## 16. File quan trọng nên biết

### Backend
- `backend_api/app/main.py`
- `backend_api/app/models/entities.py`
- `backend_api/app/routers/auth.py`
- `backend_api/app/routers/questions.py`
- `backend_api/app/routers/admin.py`

### Flutter
- `flutter_app/lib/main.dart`
- `flutter_app/lib/screens/home/home_screen.dart`
- `flutter_app/lib/screens/profile/profile_screen.dart`
- `flutter_app/lib/screens/admin/teacher_screen.dart`
- `flutter_app/lib/screens/admin/moderator_screen.dart`
- `flutter_app/lib/screens/admin/admin_screen.dart`
- `flutter_app/lib/services/auth_service.dart`
- `flutter_app/lib/services/admin_service.dart`

## 17. Lỗi thường gặp

### 1. `git add.` không chạy

Sai:

```powershell
git add.
```

Đúng:

```powershell
git add .
```

### 2. `Permission denied` khi push GitHub

Nguyên nhân:
- tài khoản GitHub hiện tại không có quyền push vào repo

Kiểm tra:

```powershell
git remote -v
ssh -T git@github.com
```

### 3. `Internal Server Error` khi login/register

Thường do:
- thiếu migration DB
- sai `MYSQL_URL`
- backend chưa restart sau khi sửa `.env`

### 4. Flutter đỏ màn hình do sai kiểu dữ liệu

Nếu gặp lỗi kiểu:

```text
type 'String' is not a subtype of type 'int'
```

thì thường là backend trả dữ liệu cũ hoặc DB chưa migrate đủ.

## 18. Gợi ý commit

Nếu muốn commit source mà không muốn add cả Flutter SDK local:

```powershell
git add backend_api database flutter_app README.md .gitignore
git commit -m "Update TOEIC Master Pro"
```

## 19. Gợi ý bàn giao cho người mới

Thứ tự khuyến nghị:

1. Clone repo
2. Tạo DB `toeic_master`
3. Import `schema.sql`
4. Chạy toàn bộ migration
5. Tạo `backend_api/.env`
6. Chạy backend
7. Chạy Flutter
8. Đăng nhập tài khoản admin hoặc tự tạo user mới
9. Gán role `teacher` / `moderator` nếu cần test nghiệp vụ

## 20. Hướng phát triển tiếp

- Tích hợp cổng thanh toán thật thay vì kiểm duyệt chuyển khoản thủ công
- Gửi thông báo khi câu hỏi được duyệt hoặc bị từ chối
- Thêm chỉnh sửa câu hỏi ngay trong màn preview import
- Thêm báo cáo doanh thu Premium
- Thêm test tự động cho backend và Flutter
