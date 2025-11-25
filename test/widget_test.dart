// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flappybee/main.dart';

void main() {
  testWidgets('Game starts correctly', (WidgetTester tester) async {
    // Set the size of the test window.
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1.0;

    // Build our app and trigger a frame.
    await tester.pumpWidget(const AbacusFlapApp());

    // Verify that the start screen is displayed.
    expect(find.text('PLAY'), findsOneWidget);
  });
}
