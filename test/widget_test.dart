import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:demo/app.dart';
import 'package:demo/controllers/calculator_controller.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Get.put(CalculatorController(prefs));
  });

  testWidgets('calculator screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    expect(find.text('Professional Calculator'), findsOneWidget);
    expect(find.text('Precision: 2'), findsOneWidget);
  });
}
