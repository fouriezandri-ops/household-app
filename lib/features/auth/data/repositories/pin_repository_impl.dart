import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/pin_repository.dart';
import 'pin_hasher.dart';

/// Stores the PIN as a PBKDF2 hash + salt in the platform secure storage
/// (iOS Keychain / Android Keystore), never in plaintext.
class PinRepositoryImpl implements PinRepository {
  PinRepositoryImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _saltKey = 'pin_salt';
  static const _hashKey = 'pin_hash';

  @override
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _hashKey);
    return hash != null;
  }

  @override
  Future<void> setPin(String pin) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash(pin, salt);
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: hash);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _saltKey);
    final storedHash = await _storage.read(key: _hashKey);
    if (salt == null || storedHash == null) return false;
    return PinHasher.hash(pin, salt) == storedHash;
  }

  @override
  Future<void> clearPin() async {
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _hashKey);
  }
}
