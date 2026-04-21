import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:calculator/app.dart';
import 'package:calculator/controllers/calculator_controller.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
  });

  setUp(() async {
    Get.reset();
    GetStorage.init('testBox');
    final GetStorage storage = GetStorage('testBox');
    await storage.erase();
    Get.put(CalculatorController());
  });

  testWidgets('calculator screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    await tester.pumpAndSettle();

    expect(find.byType(CalculatorApp), findsOneWidget);
    expect(find.textContaining('Precision:'), findsOneWidget);
  });
}
