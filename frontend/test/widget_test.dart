// AlertNest smoke test — verifies the app shell builds without errors.
import 'package:flutter_test/flutter_test.dart';
import 'package:alertnest/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AlertNestApp());
    // The app should build without throwing.
    expect(tester.takeException(), isNull);
  });
}
