# TOEIC Master Pro Flutter App

Đây là ứng dụng Flutter của project TOEIC Master Pro.

App dùng để:
- đăng ký, đăng nhập
- luyện mini test và full test TOEIC
- xem kết quả và lịch sử làm bài
- học từ vựng theo chủ đề
- sử dụng khu vực quản trị dành cho admin

## Thư mục quan trọng

```text
flutter_app/
|-- lib/
|   |-- core/         # hằng số, theme
|   |-- models/       # model dữ liệu
|   |-- screens/      # các màn hình
|   |-- services/     # gọi API, xử lý dữ liệu
|   `-- widgets/      # widget dùng lại
|-- integration_test/
|-- test/
`-- pubspec.yaml
```

## Yêu cầu

- Flutter SDK
- Android Studio hoặc VS Code
- Android Emulator hoặc điện thoại Android
- Backend của project đang chạy

## Cài thư viện

Trong thư mục `flutter_app/`, chạy:

```bash
flutter pub get
```

## Chạy app

```bash
flutter run
```

## Cấu hình API

File cấu hình API nằm tại:
- [api_constants.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/core/constants/api_constants.dart)

Hiện tại app đang dùng:
- `http://10.0.2.2:8000`

Địa chỉ này phù hợp khi chạy bằng Android emulator và backend chạy local trên máy.

## Một số file quan trọng

- [main.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/main.dart)
  Điểm khởi động của ứng dụng.

- [practice_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/practice/practice_screen.dart)
  Màn hình làm bài TOEIC.

- [result_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/practice/result_screen.dart)
  Màn hình hiển thị kết quả và review đáp án.

- [history_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/history/history_screen.dart)
  Màn hình danh sách lịch sử làm bài.

- [vocabulary_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/vocabulary/vocabulary_screen.dart)
  Màn hình học từ vựng theo chủ đề.

- [admin_screen.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/screens/admin/admin_screen.dart)
  Màn hình chính cho quản trị viên.

- [api_client.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/api_client.dart)
  Cấu hình Dio, tự động gắn token và refresh token.

- [test_service.dart](/e:/BTL_Python/toeic_app_master/flutter_app/lib/services/test_service.dart)
  Service lấy đề, nộp bài và đọc lịch sử.

## Ghi chú

- Part 2 hiện đã được chỉnh theo form demo: chỉ hiện audio và các lựa chọn A/B/C/D.
- Nếu chạy trên điện thoại thật thay vì emulator, cần đổi lại `baseUrl` cho phù hợp.
