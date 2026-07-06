import 'package:household_app/features/auth/domain/repositories/pin_repository.dart';

/// In-memory [PinRepository] for tests — avoids exercising the real
/// platform channel that `flutter_secure_storage` needs on-device.
class FakePinRepository implements PinRepository {
  String? _storedPin;

  @override
  Future<bool> hasPin() async => _storedPin != null;

  @override
  Future<void> setPin(String pin) async => _storedPin = pin;

  @override
  Future<bool> verifyPin(String pin) async => _storedPin == pin;

  @override
  Future<void> clearPin() async => _storedPin = null;
}
