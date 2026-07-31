import 'package:flutter_test/flutter_test.dart';
import 'package:sayver/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Sayver App initial smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SayverApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sayver'), findsOneWidget);
  });
}
