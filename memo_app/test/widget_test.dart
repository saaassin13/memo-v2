import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:memo_app/app.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MemoApp(),
      ),
    );

    // Verify that the app starts
    expect(find.text('今天'), findsOneWidget);
  });
}
