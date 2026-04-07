# TOEIC Master Pro

Ứng dụng luyện thi TOEIC full-stack gồm 3 phần chính:
- `backend_api`: API viết bằng FastAPI + SQLAlchemy
- `flutter_app`: ứng dụng Flutter dành cho người học và quản trị viên
- `database`: script tạo bảng, seed dữ liệu và migration hỗ trợ nhóm câu hỏi/audio

README này được viết theo hướng vừa để học code, vừa để làm báo cáo môn học.

## 1. Mục tiêu của ứng dụng

TOEIC Master Pro hỗ trợ:
- đăng ký, đăng nhập và phân quyền người dùng
- luyện mini test theo từng part
- làm full test theo cấu trúc TOEIC chuẩn
- chấm điểm và lưu lịch sử làm bài
- theo dõi tiến độ học tập theo part
- học từ vựng theo chủ đề
- quản trị người dùng, câu hỏi, chủ đề và từ vựng

## 2. Công nghệ sử dụng

### Backend

- FastAPI: xây dựng REST API
- SQLAlchemy: ORM thao tác MySQL
- PyMySQL: kết nối MySQL
- JWT: xác thực bằng access token và refresh token
- Passlib + bcrypt: băm mật khẩu
- python-multipart: upload file audio và ảnh

### Frontend

- Flutter
- Dio: gọi HTTP API
- SharedPreferences: lưu token và thông tin đăng nhập cục bộ

### Cơ sở dữ liệu

- MySQL

## 3. Chức năng chính của app

### Người dùng

- Đăng ký tài khoản mới
- Đăng nhập và tự làm mới phiên bằng refresh token
- Xem dashboard cá nhân
- Làm mini test theo từng part 1-7
- Làm full test gồm 200 câu theo phân bố chuẩn
- Nộp bài, xem điểm, xem đáp án đúng/sai
- Xem lịch sử các lần làm bài
- Bookmark câu hỏi
- Học từ vựng theo chủ đề
- Đánh dấu từ đã học
- Xem bảng xếp hạng
- Xem thống kê độ chính xác theo từng part
- Đổi mật khẩu

### Quản trị viên

- Xem danh sách người dùng
- Đổi quyền user/admin
- Reset mật khẩu người dùng
- Xóa người dùng
- Thêm, sửa, xóa câu hỏi TOEIC
- Upload audio và ảnh cho câu hỏi
- Thêm, sửa, xóa chủ đề từ vựng
- Thêm, sửa, xóa từ vựng
- Xem danh sách bài làm của người dùng
- Xem chi tiết lịch sử làm bài của từng người dùng cụ thể

### Dữ liệu TOEIC

- Hỗ trợ part 1 đến part 7
- Hỗ trợ câu độc lập và câu theo nhóm
- Hỗ trợ audio riêng từng câu hoặc audio dùng chung cho cả nhóm
- Hỗ trợ ảnh riêng hoặc ảnh dùng chung cho nhóm
- Có script gán audio demo ngẫu nhiên cho các part listening để phục vụ demo

## 4. Luồng hoạt động tổng quát

1. Người dùng đăng nhập qua Flutter app.
2. Flutter gọi API `/auth/login` để lấy `access_token` và `refresh_token`.
3. Token được lưu trong `SharedPreferences`.
4. Khi người dùng mở mini test hoặc full test, Flutter gọi API `/questions/...`.
5. Backend lấy câu hỏi từ MySQL, nhóm câu nếu cần, rồi trả về JSON.
6. Sau khi làm bài xong, Flutter gửi đáp án lên `/questions/submit`.
7. Backend chấm điểm, lưu `test_attempts`, `test_attempt_answers`, cập nhật `user_progress`.
8. Dashboard, leaderboard, lịch sử và thống kê sẽ đọc lại dữ liệu này để hiển thị.

## 5. Cấu trúc thư mục của project

```text
toeic_app_master/
|-- backend_api/
|-- database/
|-- flutter_app/
|-- .gitignore
`-- README.md
```

Lưu ý:
- `flutter_app/` mới là app Flutter của dự án.
- `E:\BTL_Python\flutter` là Flutter SDK cài ngoài project, không phải source app.
- Thư mục build, cache, `.dart_tool`, `__pycache__`, `.gradle` không có giá trị báo cáo nên không phân tích chi tiết ở đây.

## 6. Giải thích từng thư mục và file quan trọng

## 6.1. Thư mục `database/`

Chứa script SQL và script hỗ trợ sinh dữ liệu.

- [generate_toeic_seed.py](/e:/BTL_Python/toeic_app_master/database/generate_toeic_seed.py)
  Script Python hỗ trợ sinh dữ liệu seed TOEIC.

- [migrate_question_grouping.sql](/e:/BTL_Python/toeic_app_master/database/migrate_question_grouping.sql)
  Migration bổ sung cấu trúc nhóm câu hỏi như `group_key`, `question_order`, `shared_audio_url`, `shared_image_url`, và có thể gán audio demo ngẫu nhiên cho part nghe.

- [schema.sql](/e:/BTL_Python/toeic_app_master/database/schema.sql)
  File quan trọng nhất của database. Tạo bảng, tạo dữ liệu mẫu và tài khoản mẫu.

- [seed_questions_only.sql](/e:/BTL_Python/toeic_app_master/database/seed_questions_only.sql)
  Seed riêng phần câu hỏi, dùng khi không muốn import toàn bộ schema.

- [seed_toeic_full_test_200.sql](/e:/BTL_Python/toeic_app_master/database/seed_toeic_full_test_200.sql)
  Seed bộ câu hỏi phục vụ full test 200 câu.

- [seed_vocabularies.sql](/e:/BTL_Python/toeic_app_master/database/seed_vocabularies.sql)
  Seed dữ liệu từ vựng và chủ đề từ vựng.

## 6.2. Thư mục `backend_api/`

Đây là phần máy chủ API.

### File cấu hình gốc

- [requirements.txt](/e:/BTL_Python/toeic_app_master/backend_api/requirements.txt)
  Danh sách thư viện Python cần cài cho backend.

- [.env.example](/e:/BTL_Python/toeic_app_master/backend_api/.env.example)
  File mẫu cấu hình biến môi trường, gồm chuỗi kết nối MySQL và JWT secret.

### Thư mục `app/`

Chứa toàn bộ source backend.

#### `app/main.py`

- [main.py](/e:/BTL_Python/toeic_app_master/backend_api/app/main.py)
  Điểm khởi động của FastAPI.
  Nhiệm vụ chính:
  - tạo đối tượng `FastAPI`
  - tạo thư mục `uploads/audio` và `uploads/images` nếu chưa có
  - mount static files tại `/uploads`
  - đăng ký các router `auth`, `progress`, `questions`, `admin`, `vocabulary`, `stats`

#### `app/core/`

- [config.py](/e:/BTL_Python/toeic_app_master/backend_api/app/core/config.py)
  Đọc cấu hình từ `.env`. Hiện tại dùng `MYSQL_URL` và `JWT_SECRET`.

- [database.py](/e:/BTL_Python/toeic_app_master/backend_api/app/core/database.py)
  Khởi tạo engine SQLAlchemy, session và `Base` cho ORM.

- [security.py](/e:/BTL_Python/toeic_app_master/backend_api/app/core/security.py)
  Xử lý bảo vệ route:
  - đọc bearer token
  - lấy người dùng hiện tại từ access token
  - kiểm tra quyền admin bằng `require_admin`

#### `app/models/`

- [entities.py](/e:/BTL_Python/toeic_app_master/backend_api/app/models/entities.py)
  Định nghĩa các bảng ORM chính:
  - `User`
  - `Question`
  - `UserProgress`
  - `TestAttempt`
  - `TestAttemptAnswer`
  - `UserBookmark`
  - `Topic`
  - `VocabularyWord`
  - `UserStudiedWord`
  - `RefreshToken`

  Đây là file rất quan trọng để bạn giải thích mô hình dữ liệu trong báo cáo.

#### `app/schemas/`

Chứa model Pydantic dùng để kiểm tra dữ liệu vào/ra của API.

- [auth.py](/e:/BTL_Python/toeic_app_master/backend_api/app/schemas/auth.py)
  Schema cho đăng ký, đăng nhập, refresh token, đổi mật khẩu.

- [progress.py](/e:/BTL_Python/toeic_app_master/backend_api/app/schemas/progress.py)
  Schema trả về tiến độ học tập.

- [question.py](/e:/BTL_Python/toeic_app_master/backend_api/app/schemas/question.py)
  Schema tạo/sửa câu hỏi, submit bài và tóm tắt lần làm bài.

- [topic.py](/e:/BTL_Python/toeic_app_master/backend_api/app/schemas/topic.py)
  Schema dữ liệu chủ đề.

- [vocabulary.py](/e:/BTL_Python/toeic_app_master/backend_api/app/schemas/vocabulary.py)
  Schema dữ liệu từ vựng.

#### `app/services/`

- [auth_service.py](/e:/BTL_Python/toeic_app_master/backend_api/app/services/auth_service.py)
  Chứa logic nghiệp vụ xác thực:
  - băm mật khẩu
  - kiểm tra mật khẩu
  - tạo access token
  - tạo refresh token
  - giải mã token

#### `app/utils/`

- [file_upload.py](/e:/BTL_Python/toeic_app_master/backend_api/app/utils/file_upload.py)
  File tiện ích liên quan upload. Nếu báo cáo về phần media upload, bạn có thể nhắc file này như helper.

#### `app/routers/`

Mỗi file router tương ứng một nhóm API.

- [auth.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/auth.py)
  API xác thực:
  - `/auth/register`
  - `/auth/login`
  - `/auth/refresh`
  - `/auth/change-password`
  - `/auth/me`

- [questions.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/questions.py)
  API quan trọng nhất của hệ thống luyện đề:
  - lấy danh sách câu hỏi
  - tạo mini test
  - tạo full test
  - chọn ngẫu nhiên theo cấu trúc part
  - xử lý nhóm câu hỏi part 3, 4, 6, 7
  - nộp bài và chấm điểm
  - lưu lịch sử làm bài
  - bookmark câu hỏi
  - tạo/sửa/xóa câu hỏi ở mức API

- [progress.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/progress.py)
  API lấy tiến độ cá nhân của người dùng.

- [stats.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/stats.py)
  API dashboard và thống kê:
  - dashboard tổng quan
  - leaderboard
  - thống kê độ chính xác theo từng part

- [topics.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/topics.py)
  API lấy danh sách chủ đề.

- [vocabulary.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/vocabulary.py)
  API từ vựng:
  - danh sách từ
  - lọc theo chủ đề
  - đánh dấu đã học
  - bỏ đánh dấu đã học
  - lấy danh sách từ đã học

- [admin.py](/e:/BTL_Python/toeic_app_master/backend_api/app/routers/admin.py)
  API quản trị:
  - quản lý user
  - quản lý câu hỏi
  - upload audio/ảnh
  - quản lý chủ đề
  - quản lý từ vựng
  - xem danh sách bài làm của user
  - xem chi tiết từng bài làm của user theo `attempt_id`

### Thư mục `uploads/`

Chứa file media mà backend phục vụ tĩnh:
- `uploads/audio`: file nghe
- `uploads/images`: ảnh minh họa

## 6.3. Thư mục `flutter_app/`

Đây là ứng dụng di động Flutter.

### File cấu hình dự án

- [pubspec.yaml](/e:/BTL_Python/toeic_app_master/flutter_app/pubspec.yaml)
  Khai báo package Flutter, assets và dependencies.

- [android/gradle.properties](/e:/BTL_Python/toeic_app_master/flutter_app/android/gradle.properties)
  Cấu hình Gradle Android. Hiện có chỉnh thêm để build ổn định hơn trên Windows.

### Thư mục `lib/`

Chứa source chính của Flutter app.

#### `lib/main.dart`

- [main.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/main.dart)
  Điểm khởi động của ứng dụng Flutter.
  Luồng chính:
  - chạy `ToeicApp`
  - dùng `SplashGate` kiểm tra người dùng đã đăng nhập chưa
  - nếu là admin thì vào `AdminScreen`
  - nếu là user thì vào `HomeScreen`
  - nếu chưa đăng nhập thì vào `LoginScreen`

#### `lib/core/constants/`

- [api_constants.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/core/constants/api_constants.dart)
  Chứa toàn bộ URL API.
  Hiện dùng `http://10.0.2.2:8000` để emulator Android truy cập backend local.

#### `lib/core/theme/`

- [app_theme.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/core/theme/app_theme.dart)
  Khai báo theme chung cho app: màu sắc, typography, style widget.

#### `lib/models/`

Các file model dùng để parse JSON từ backend sang đối tượng Dart.

- [attempt_model.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/models/attempt_model.dart)
  Model cho lịch sử bài làm.

- [progress_model.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/models/progress_model.dart)
  Model cho tiến độ học tập.

- [question_model.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/models/question_model.dart)
  Model câu hỏi TOEIC, rất quan trọng vì liên quan part, option, audio, group.

- [user_model.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/models/user_model.dart)
  Model người dùng.

- [vocabulary_word_model.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/models/vocabulary_word_model.dart)
  Model từ vựng.

#### `lib/services/`

Đây là lớp trung gian giữa UI Flutter và backend API.

- [api_client.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/api_client.dart)
  Khởi tạo `Dio`, tự động gắn access token vào request và tự refresh token khi bị `401`.

- [auth_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/auth_service.dart)
  Gọi API đăng nhập, đăng ký, lấy thông tin người dùng, đổi mật khẩu, logout.

- [app_data_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/app_data_service.dart)
  Gọi API dashboard, progress, leaderboard, part stats, vocabulary.

- [audio_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/audio_service.dart)
  Xử lý phát audio trong các part nghe.

- [progress_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/progress_service.dart)
  Đóng gói thao tác với dữ liệu tiến độ nếu UI cần dùng riêng.

- [question_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/question_service.dart)
  Phục vụ các thao tác lấy câu hỏi hoặc chi tiết liên quan câu hỏi.

- [test_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/test_service.dart)
  Service quan trọng cho tính năng luyện đề:
  - lấy mini test
  - lấy full test
  - submit bài
  - lấy lịch sử bài làm
  - bookmark câu hỏi

- [admin_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/admin_service.dart)
  Service dành cho màn hình admin:
  - quản lý user
  - quản lý câu hỏi
  - lấy danh sách bài làm theo từng user
  - lấy chi tiết bài làm để admin review

#### `lib/screens/`

Mỗi thư mục con là một nhóm màn hình.

##### `screens/auth/`

- [login_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/auth/login_screen.dart)
  Giao diện đăng nhập.

- [register_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/auth/register_screen.dart)
  Giao diện đăng ký tài khoản mới.

##### `screens/home/`

- [home_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/home/home_screen.dart)
  Màn hình chính của user sau khi đăng nhập, đóng vai trò điều hướng đến luyện đề, từ vựng, bảng xếp hạng, lịch sử, hồ sơ.

##### `screens/practice/`

- [practice_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/practice/practice_screen.dart)
  Màn hình làm bài thi. Đây là file trung tâm của phần luyện đề:
  - hiển thị câu hỏi
  - điều hướng câu
  - phát audio
  - quản lý timer
  - nhận đáp án người dùng
  - xử lý khác nhau giữa mini test và full test
  - part 2 hiện được chỉnh theo form demo chỉ gồm audio và lựa chọn A/B/C/D

- [result_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/practice/result_screen.dart)
  Màn hình kết quả sau khi nộp bài:
  - điểm số
  - số câu đúng
  - thống kê theo part
  - review đáp án

##### `screens/history/`

- [history_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/history/history_screen.dart)
  Hiển thị danh sách các lần làm bài trước đây.

- [history_detail_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/history/history_detail_screen.dart)
  Hiển thị chi tiết 1 lần làm bài và review đáp án.

##### `screens/vocabulary/`

- [vocabulary_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/vocabulary/vocabulary_screen.dart)
  Giao diện học từ vựng, lọc theo chủ đề, đánh dấu đã học.

##### `screens/leaderboard/`

- [leaderboard_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/leaderboard/leaderboard_screen.dart)
  Hiển thị bảng xếp hạng người học.

##### `screens/profile/`

- [profile_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/profile/profile_screen.dart)
  Hiển thị thông tin cá nhân và thao tác liên quan tài khoản.

##### `screens/admin/`

- [admin_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/admin_screen.dart)
  Màn hình tổng quan admin, thường là điểm vào các chức năng quản trị.

- [admin_topic_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/admin_topic_screen.dart)
  Quản lý chủ đề từ vựng.

- [admin_vocabulary_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/admin_vocabulary_screen.dart)
  Quản lý từ vựng.

- [create_question_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/create_question_screen.dart)
  Form thêm mới hoặc chỉnh sửa câu hỏi TOEIC.

- [manage_questions_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/manage_questions_screen.dart)
  Danh sách câu hỏi để admin lọc, sửa, xóa.

- [manage_users_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/manage_users_screen.dart)
  Quản lý danh sách người dùng, quyền, reset mật khẩu và mở lịch sử làm bài của từng user.

- [user_attempts_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/user_attempts_screen.dart)
  Hiển thị danh sách các bài làm của một người dùng cụ thể để admin chọn xem.

#### `lib/widgets/`

- [dashboard_card.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/widgets/dashboard_card.dart)
  Widget card dùng lại trong dashboard/trang chủ.

- [ptit_logo.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/widgets/ptit_logo.dart)
  Widget logo/trang trí của ứng dụng.

## 7. Các bảng dữ liệu chính

Bạn có thể trình bày phần này trong báo cáo để mô tả ERD đơn giản.

- `users`: lưu tài khoản, role, mục tiêu điểm
- `questions`: lưu câu hỏi TOEIC, đáp án, audio, ảnh, group
- `user_progress`: lưu tiến độ học tập và thống kê tổng hợp
- `test_attempts`: lưu mỗi lần nộp bài
- `test_attempt_answers`: lưu đáp án từng câu trong mỗi lần làm bài
- `user_bookmarks`: lưu câu hỏi được đánh dấu
- `topics`: lưu chủ đề từ vựng
- `vocabulary_words`: lưu từ vựng
- `user_studied_words`: lưu từ người dùng đã học
- `refresh_tokens`: lưu refresh token để quản lý phiên đăng nhập

## 8. Cấu trúc đề TOEIC trong app

Backend đang xây theo phân bố:
- Part 1: 6 câu
- Part 2: 25 câu
- Part 3: 39 câu
- Part 4: 30 câu
- Part 5: 30 câu
- Part 6: 16 câu
- Part 7: 54 câu

Mini test cũng có phân bố riêng theo từng part để luyện nhanh.

## 9. Audio demo hiện tại

Để tiện demo, dữ liệu đang được gán audio ngẫu nhiên như sau:
- file tên chứa `U2` cho Part 1
- file tên chứa `U4` cho Part 2
- file tên chứa `U8` cho Part 3 và Part 4

Việc gán này được xử lý trong [migrate_question_grouping.sql](/e:/BTL_Python/toeic_app_master/database/migrate_question_grouping.sql) và cho phép lặp lại file audio, vì mục tiêu chính là demo chức năng nghe.

## 10. Tài khoản mẫu

Theo dữ liệu trong [schema.sql](/e:/BTL_Python/toeic_app_master/database/schema.sql):

- Admin
  - Email: `admin@toeic.com`
  - Mật khẩu: `123456`

- User
  - Email: `student@toeic.com`
  - Mật khẩu: `123456`

## 11. Hướng dẫn cài đặt và chạy project

### Bước 1: Tạo database

```sql
CREATE DATABASE toeic_master CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Bước 2: Import dữ liệu

Trong thư mục project:

```powershell
mysql -u root -p toeic_master < database/schema.sql
```

Nếu cần có thể import thêm các file seed riêng tùy mục đích demo.

### Bước 3: Chạy backend

```powershell
cd E:\BTL_Python\toeic_app_master\backend_api
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Tạo file `.env` từ `.env.example`:

```env
MYSQL_URL=mysql+pymysql://root:123456@localhost:3306/toeic_master?charset=utf8mb4
JWT_SECRET=your_super_secret_key_here
```

Chạy server:

```powershell
uvicorn app.main:app --reload
```

API mặc định:
- `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`

### Bước 4: Chạy Flutter app

```powershell
cd E:\BTL_Python\toeic_app_master\flutter_app
flutter pub get
flutter run
```

Lưu ý:
- `ApiConstants.baseUrl` hiện là `http://10.0.2.2:8000`
- địa chỉ này đúng khi chạy Android emulator và backend đang chạy local trên máy

## 12. Một số điểm kỹ thuật đáng chú ý để đưa vào báo cáo

- Ứng dụng dùng kiến trúc tách lớp rõ ràng: `UI -> Service -> API -> Database`
- Flutter lưu token cục bộ và tự refresh khi access token hết hạn
- Backend phân quyền bằng `require_admin`
- Backend lưu lịch sử từng lần thi và từng câu trả lời
- Câu hỏi hỗ trợ nhóm câu để mô phỏng đúng dạng TOEIC thật
- Media upload được phục vụ qua static route `/uploads`
- Part 2 đã được chỉnh theo dạng thi thực tế để chỉ hiện audio và lựa chọn A/B/C/D trong màn hình làm bài/demo

## 13. Gợi ý trình bày báo cáo

Nếu bạn viết báo cáo đồ án, có thể chia chương như sau:

1. Giới thiệu đề tài và mục tiêu
2. Công nghệ sử dụng
3. Phân tích chức năng hệ thống
4. Thiết kế cơ sở dữ liệu
5. Thiết kế backend API
6. Thiết kế giao diện Flutter
7. Kết quả chạy thử
8. Hướng phát triển

## 14. Hướng phát triển tiếp theo

- bổ sung chấm điểm TOEIC quy đổi chuẩn thay vì đếm số câu đúng
- thêm bookmark và lọc câu yếu ngay trên giao diện
- thêm đề ngẫu nhiên đa dạng hơn cho mini test
- thêm thống kê theo thời gian học
- triển khai cloud storage cho audio/ảnh thay vì lưu local
- bổ sung test tự động cho backend và Flutter
