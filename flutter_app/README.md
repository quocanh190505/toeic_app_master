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
|- lib/
|  |- core/         # hằng số, theme
|  |- models/       # model dữ liệu
|  |- screens/      # các màn hình
|  |- services/     # gọi API, xử lý dữ liệu
|  `- widgets/      # widget dùng lại
|- integration_test/
|- test/
`- pubspec.yaml
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

Nếu đang dùng Android emulator và backend chạy local trên máy tính, app hiện được cấu hình để gọi API qua:

```text
http://10.0.2.2:8000
```

File cấu hình:

- [lib/core/constants/api_constants.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/core/constants/api_constants.dart)

## Build APK

Nếu muốn build file cài đặt thử nghiệm:

```bash
flutter build apk --release
```

File tạo ra nằm tại:

- [build/app/outputs/flutter-apk/app-release.apk](/d:/pythontest/toeic_fullstack_project/flutter_app/build/app/outputs/flutter-apk/app-release.apk)

## Một số màn hình chính

- [lib/screens/auth/login_screen.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/auth/login_screen.dart)
- [lib/screens/auth/register_screen.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/auth/register_screen.dart)
- [lib/screens/home/home_screen.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/home/home_screen.dart)
- [lib/screens/practice/practice_screen.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/practice/practice_screen.dart)
- [lib/screens/admin/admin_screen.dart](/d:/pythontest/toeic_fullstack_project/flutter_app/lib/screens/admin/admin_screen.dart)

## Ghi chú

- `flutter_app/` là app chính, không phải thư mục `flutter/`.
- Nếu tiếng Việt bị lỗi dấu trong file Dart, hãy lưu file bằng `UTF-8`.
- Full test hiện đã có đồng hồ đếm giờ và tự nộp bài khi hết thời gian.
- Nếu đổi môi trường chạy API, chỉ cần sửa `baseUrl` trong `api_constants.dart`.

## Test

```bash
flutter test
flutter test integration_test
```

## Liên kết với project tổng

Đây chỉ là phần frontend Flutter. Để chạy đầy đủ hệ thống, hãy xem README gốc của project:

- [README.md](/d:/pythontest/toeic_fullstack_project/README.md)
