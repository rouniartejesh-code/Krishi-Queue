import 'package:flutter_test/flutter_test.dart';
import 'package:krishi_queue/main.dart';

void main() {
  testWidgets('Krishi Queue login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KrishiQueueApp());

    expect(find.text('Krishi Queue'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
  });
}