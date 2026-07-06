import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/pin_repository_impl.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/repositories/pin_repository.dart';

part 'auth_providers.g.dart';

@riverpod
PinRepository pinRepository(Ref ref) {
  return PinRepositoryImpl(const FlutterSecureStorage());
}

/// Drives the PIN gate: whether a PIN exists, and whether it's currently
/// unlocked for this session.
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AuthStatus> build() async {
    final repository = ref.watch(pinRepositoryProvider);
    return await repository.hasPin() ? AuthStatus.locked : AuthStatus.noPinSet;
  }

  /// First-run flow: stores [pin] and unlocks immediately.
  Future<void> createPin(String pin) async {
    final repository = ref.read(pinRepositoryProvider);
    await repository.setPin(pin);
    state = const AsyncData(AuthStatus.unlocked);
  }

  /// Returns whether [pin] was correct. On success, unlocks the session.
  Future<bool> unlock(String pin) async {
    final repository = ref.read(pinRepositoryProvider);
    final isCorrect = await repository.verifyPin(pin);
    if (isCorrect) {
      state = const AsyncData(AuthStatus.unlocked);
    }
    return isCorrect;
  }

  /// Re-locks the session, e.g. after the inactivity threshold elapses.
  void lock() {
    if (state.value == AuthStatus.unlocked) {
      state = const AsyncData(AuthStatus.locked);
    }
  }
}
