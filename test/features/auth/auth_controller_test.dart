import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/features/auth/domain/entities/auth_status.dart';
import 'package:household_app/features/auth/presentation/providers/auth_providers.dart';

import 'fake_pin_repository.dart';

void main() {
  late FakePinRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakePinRepository();
    container = ProviderContainer(
      overrides: [pinRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
  });

  test('starts at noPinSet when no PIN has ever been stored', () async {
    final status = await container.read(authControllerProvider.future);
    expect(status, AuthStatus.noPinSet);
  });

  test('createPin stores the PIN and unlocks immediately', () async {
    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).createPin('1234');

    expect(container.read(authControllerProvider).value, AuthStatus.unlocked);
    expect(await fakeRepository.hasPin(), isTrue);
  });

  test('unlock succeeds with the correct PIN and fails with the wrong one', () async {
    await container.read(authControllerProvider.future);
    await container.read(authControllerProvider.notifier).createPin('1234');
    container.read(authControllerProvider.notifier).lock();

    final wrongAttempt = await container.read(authControllerProvider.notifier).unlock('0000');
    expect(wrongAttempt, isFalse);
    expect(container.read(authControllerProvider).value, AuthStatus.locked);

    final rightAttempt = await container.read(authControllerProvider.notifier).unlock('1234');
    expect(rightAttempt, isTrue);
    expect(container.read(authControllerProvider).value, AuthStatus.unlocked);
  });

  test('lock() is a no-op when already locked', () async {
    await container.read(authControllerProvider.future);
    container.read(authControllerProvider.notifier).lock();
    expect(container.read(authControllerProvider).value, AuthStatus.noPinSet);
  });
}
