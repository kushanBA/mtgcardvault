import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cardvault_flutter/main.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const CardVaultApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
