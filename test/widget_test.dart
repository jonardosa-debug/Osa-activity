import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jonard_project/app.dart';

void main() {
  testWidgets('Login first, Sign In opens the home dashboard',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SmartTrackApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign in to SmartTrack'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Jonard Osa!'), findsOneWidget);
  });

  testWidgets('Home Quick Actions opens the Report Form (Activity 9)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SmartTrackApp());

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Navigate: Home dashboard -> File a Report quick action (scroll into view).
    await tester.scrollUntilVisible(
      find.text('File a Report'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('File a Report'));
    await tester.pumpAndSettle();

    expect(find.text('Report Form'), findsOneWidget);
    expect(find.text('File a New Report'), findsOneWidget);

    // EMPTY state: no submitted reports yet.
    expect(find.text('No reports available'), findsOneWidget);

    // Invalid submit -> field-level validation, no state change.
    await tester.tap(find.text('Submit Report'));
    await tester.pumpAndSettle();
    expect(find.text('Report title is required.'), findsOneWidget);
    expect(find.text('Destination country is required.'), findsOneWidget);

    // Fill valid data -> Loading -> Success.
    await tester.enterText(find.byType(TextFormField).at(0), 'Delayed travel document');
    await tester.enterText(find.byType(TextFormField).at(1), 'Japan');
    await tester.enterText(find.byType(TextFormField).at(2), 'Submitted the required travel documents late.');
    await tester.tap(find.text('Submit Report'));
    await tester.pump(); // start async submit
    await tester.pump(const Duration(seconds: 1)); // still loading
    expect(find.text('Submitting your report…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3)); // simulated delay completes
    await tester.pumpAndSettle();
    expect(find.text('Report submitted successfully'), findsOneWidget);
    expect(find.textContaining('RPT-'), findsWidgets); // success card + list

    // Clear records -> EMPTY state is reproducible again.
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('No reports available'), findsOneWidget);
  });

  testWidgets('Simulated failure shows Error state with Retry (Activity 9)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SmartTrackApp());

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('File a Report'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('File a Report'));
    await tester.pumpAndSettle();

    // Turn on the demo failure toggle.
    await tester.tap(find.text('Simulate a failure (demo only)'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Delayed travel document');
    await tester.enterText(find.byType(TextFormField).at(1), 'Japan');
    await tester.enterText(find.byType(TextFormField).at(2), 'Submitted the required travel documents late.');
    await tester.tap(find.text('Submit Report'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // ERROR state with a visible Retry action.
    expect(find.text('Submission failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    // Retry with the toggle still on fails again (proves Retry re-submits).
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Submission failed'), findsOneWidget);
  });
}
