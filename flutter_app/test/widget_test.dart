import 'package:flutter_test/flutter_test.dart';
// Giữ nguyên dòng import file main của bạn ở đây
import 'package:toeic_master_pro/main.dart'; 

void main() {
  testWidgets('app builds successfully', (WidgetTester tester) async {
    // Đổi thành ToeicApp
    await tester.pumpWidget(const ToeicApp()); 
    // Đổi thành ToeicApp
    expect(find.byType(ToeicApp), findsOneWidget); 
  });
}