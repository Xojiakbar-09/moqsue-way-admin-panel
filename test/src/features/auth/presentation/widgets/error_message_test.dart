import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_admin/src/features/auth/presentation/widgets/error_message.dart';

void main() {
  group('ErrorMessage', () {
    testWidgets('berilgan xabarni ko‘rsatadi', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorMessage('Xato yuz berdi')),
        ),
      );

      expect(find.text('Xato yuz berdi'), findsOneWidget);
    });
  });
}
