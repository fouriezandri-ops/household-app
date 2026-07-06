import 'package:flutter_test/flutter_test.dart';
import 'package:household_app/features/auth/data/repositories/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('same PIN and salt always hash to the same value', () {
      final salt = PinHasher.generateSalt();
      expect(PinHasher.hash('1234', salt), PinHasher.hash('1234', salt));
    });

    test('different PINs hash differently under the same salt', () {
      final salt = PinHasher.generateSalt();
      expect(PinHasher.hash('1234', salt), isNot(PinHasher.hash('4321', salt)));
    });

    test('the same PIN hashes differently under different salts', () {
      final saltA = PinHasher.generateSalt();
      final saltB = PinHasher.generateSalt();
      expect(PinHasher.hash('1234', saltA), isNot(PinHasher.hash('1234', saltB)));
    });

    test('generateSalt produces distinct salts', () {
      expect(PinHasher.generateSalt(), isNot(PinHasher.generateSalt()));
    });
  });
}
