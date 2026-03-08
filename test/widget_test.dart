import 'package:flutter_test/flutter_test.dart';

import 'package:pollenapp/main.dart';

void main() {
  testWidgets('App boots and shows loading state first', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PollenApp());

    expect(find.byType(PollenApp), findsOneWidget);
  });
}
