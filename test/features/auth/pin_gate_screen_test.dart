import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:household_app/features/auth/presentation/screens/pin_gate_screen.dart';

import 'fake_pin_repository.dart';

Future<void> _enterDigits(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
}

void main() {
  testWidgets('first run: creating a PIN requires matching confirmation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pinRepositoryProvider.overrideWithValue(FakePinRepository())],
        child: const MaterialApp(home: PinGateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create a PIN'), findsOneWidget);

    await _enterDigits(tester, '1234');
    await tester.pumpAndSettle();
    expect(find.text('Confirm your PIN'), findsOneWidget);

    await _enterDigits(tester, '0000');
    await tester.pumpAndSettle();
    expect(find.text("PINs didn't match — try again"), findsOneWidget);
    expect(find.text('Create a PIN'), findsOneWidget);
  });

  testWidgets('unlock: wrong PIN shows an error and clears entry', (tester) async {
    final fakeRepository = FakePinRepository();
    await fakeRepository.setPin('1234');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [pinRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: PinGateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter your PIN'), findsOneWidget);

    await _enterDigits(tester, '0000');
    await tester.pumpAndSettle();
    expect(find.text('Incorrect PIN'), findsOneWidget);
  });
}
