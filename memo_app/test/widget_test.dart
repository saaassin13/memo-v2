import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo_app/app.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    // Set a larger surface to avoid layout overflow
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MemoApp(),
      ),
    );

    // Verify that the app starts
    expect(find.text('今天'), findsOneWidget);
  });
}
