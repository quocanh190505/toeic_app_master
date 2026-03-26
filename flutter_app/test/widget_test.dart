import 'package:flutter_test/flutter_test.dart';
import 'package:toeic_master_pro/main.dart';

void main() {
  testWidgets('app builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ToeicMasterProApp());
    expect(find.byType(ToeicMasterProApp), findsOneWidget);
  });
}