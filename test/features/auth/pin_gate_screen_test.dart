import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/features/auth/domain/repositories/pin_repository.dart';
import 'package:household_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:household_app/features/auth/presentation/screens/pin_gate_screen.dart';

import 'fake_pin_repository.dart';

Future<void> _enterDigits(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(find.text(digit));
    await tester.pump();
  }
}

/// Simulates a Keystore/Keychain failure (e.g. `FlutterSecureStorage.write`
/// throwing a `PlatformException`) to verify the PIN gate recovers instead
/// of leaving the keypad stuck.
class _ThrowingPinRepository implements PinRepository {
  @override
  Future<bool> hasPin() async => false;

  @override
  Future<void> setPin(String pin) async => throw Exception('Keystore unavailable');

  @override
  Future<bool> verifyPin(String pin) async => throw Exception('Keystore unavailable');

  @override
  Future<void> clearPin() async {}
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

  testWidgets('a storage failure shows an error and leaves the keypad usable', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pinRepositoryProvider.overrideWithValue(_ThrowingPinRepository())],
        child: const MaterialApp(home: PinGateScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await _enterDigits(tester, '1234');
    await tester.pumpAndSettle();
    // First entry just asks for confirmation — no repository call yet.
    expect(find.text('Confirm your PIN'), findsOneWidget);

    await _enterDigits(tester, '1234');
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong — please try again'), findsOneWidget);

    // The keypad isn't stuck: entering another digit is accepted.
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(find.text('Something went wrong — please try again'), findsNothing);
  });
}
