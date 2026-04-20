import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitality/main.dart';

void main() {
  testWidgets('VITality app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VITalityApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
