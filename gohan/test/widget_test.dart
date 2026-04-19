import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gohan/main.dart';

void main() {
  testWidgets('App boots and renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GohanApp()));
    // Splash is shown while the session loads from secure storage.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
