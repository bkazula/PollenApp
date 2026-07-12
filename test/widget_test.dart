import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pollenapp/main.dart';
import 'package:pollenapp/models/app_location.dart';
import 'package:pollenapp/models/pollen_entry.dart';

const AppLocation _testLocation = AppLocation(
  latitude: 52.2297,
  longitude: 21.0122,
  label: 'Warsaw',
);

void main() {
  testWidgets('App displays pollen data for a saved location', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PollenApp(
        savedLocationLoader: () async => _testLocation,
        pollenDataLoader: ({required latitude, required longitude}) async =>
            <PollenEntry>[const PollenEntry(name: 'Birch', intensity: 'High')],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pollen for: Warsaw'), findsOneWidget);
    expect(find.text('Birch'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets(
    'App keeps saved-location bootstrap future across locale changes',
    (WidgetTester tester) async {
      int savedLocationLoadCount = 0;

      await tester.pumpWidget(
        PollenApp(
          savedLocationLoader: () async {
            savedLocationLoadCount += 1;
            return _testLocation;
          },
          pollenDataLoader: ({required latitude, required longitude}) async =>
              <PollenEntry>[const PollenEntry(name: 'Grass', intensity: 'Low')],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Polski').last);
      await tester.pumpAndSettle();

      expect(savedLocationLoadCount, 1);
      expect(find.text('Pylenie dla: Warsaw'), findsOneWidget);
      expect(find.text('Grass'), findsOneWidget);
      expect(find.text('Niskie'), findsOneWidget);
    },
  );

  testWidgets('Pollen errors show only a safe localized message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      PollenApp(
        savedLocationLoader: () async => _testLocation,
        pollenDataLoader: ({required latitude, required longitude}) async =>
            throw StateError('SECRET_API_KEY_SHOULD_NOT_RENDER'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Error loading data from Google Pollen API.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('SECRET_API_KEY_SHOULD_NOT_RENDER'),
      findsNothing,
    );
  });
}
