import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Salted PBKDF2-HMAC-SHA256 hashing for the household PIN.
///
/// A single SHA-256(salt + pin) would be crackable in well under a second
/// given the tiny keyspace of a 4-6 digit PIN, so this stretches it with a
/// configurable iteration count instead — cheap enough to run once at
/// unlock time, expensive enough to matter if the secure-storage blob were
/// ever extracted from the device.
abstract final class PinHasher {
  static const _iterations = 120000;
  static const _keyLength = 32;
  static const _saltLength = 16;

  /// Generates a new random salt.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List.generate(_saltLength, (_) => random.nextInt(256)),
    );
    return base64Url.encode(bytes);
  }

  /// Derives a hash for [pin] using [saltBase64], returned as base64.
  static String hash(String pin, String saltBase64) {
    final salt = base64Url.decode(saltBase64);
    final derived = _pbkdf2(utf8.encode(pin), salt, _iterations, _keyLength);
    return base64Url.encode(derived);
  }

  /// SHA-256 digest length in bytes (PBKDF2's "hLen").
  static const _hashLength = 32;

  static Uint8List _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final blockCount = (keyLength / _hashLength).ceil();
    final output = BytesBuilder();

    for (var blockIndex = 1; blockIndex <= blockCount; blockIndex++) {
      final blockIndexBytes = ByteData(4)..setUint32(0, blockIndex, Endian.big);
      var u = hmac.convert([...salt, ...blockIndexBytes.buffer.asUint8List()]).bytes;
      final blockResult = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < blockResult.length; j++) {
          blockResult[j] ^= u[j];
        }
      }
      output.add(blockResult);
    }

    return output.toBytes().sublist(0, keyLength);
  }
}
