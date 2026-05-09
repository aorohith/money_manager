import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/security/pin_hasher.dart';

void main() {
  // Light iteration count keeps unit tests fast (< 50 ms) while still
  // exercising the full PBKDF2 chain.
  const fastIterations = 1000;

  group('PinHasher', () {
    test('encoded format starts with the canonical pbkdf2 prefix', () {
      const hasher = PinHasher();
      final encoded = hasher.hash('123456', iterations: fastIterations);
      expect(encoded.startsWith('pbkdf2\$$fastIterations\$'), isTrue);
      expect(encoded.split(r'$'), hasLength(4));
    });

    test('verify accepts the original PIN and rejects mismatches', () {
      const hasher = PinHasher();
      final encoded = hasher.hash('123456', iterations: fastIterations);
      expect(hasher.verify('123456', encoded), isTrue);
      expect(hasher.verify('123450', encoded), isFalse);
      expect(hasher.verify('', encoded), isFalse);
    });

    test('two hashes of the same PIN have different salts', () {
      const hasher = PinHasher();
      final a = hasher.hash('123456', iterations: fastIterations);
      final b = hasher.hash('123456', iterations: fastIterations);
      expect(a, isNot(b));
      expect(hasher.verify('123456', a), isTrue);
      expect(hasher.verify('123456', b), isTrue);
    });

    test('verify falls back to constant-time string compare for legacy values',
        () {
      const hasher = PinHasher();
      expect(hasher.verify('123456', '123456'), isTrue);
      expect(hasher.verify('000000', '123456'), isFalse);
      expect(hasher.isHashed('123456'), isFalse);
    });

    test('isHashed identifies the canonical encoded format', () {
      const hasher = PinHasher();
      final encoded = hasher.hash('123456', iterations: fastIterations);
      expect(hasher.isHashed(encoded), isTrue);
      expect(hasher.isHashed('not-a-hash'), isFalse);
    });

    test('rejects malformed encoded values without throwing', () {
      const hasher = PinHasher();
      expect(hasher.verify('123456', 'pbkdf2\$abc\$AA==\$BB=='), isFalse);
      expect(hasher.verify('123456', 'pbkdf2\$1\$not-base64\$x'), isFalse);
      expect(hasher.verify('123456', 'pbkdf2\$1\$AA=='), isFalse);
    });
  });

  group('constant-time helpers', () {
    test('constantTimeEqualBytes compares values, not references', () {
      expect(constantTimeEqualBytes([1, 2, 3], [1, 2, 3]), isTrue);
      expect(constantTimeEqualBytes([1, 2, 3], [1, 2, 4]), isFalse);
      expect(constantTimeEqualBytes([1, 2, 3], [1, 2]), isFalse);
    });

    test('constantTimeEqualString matches identical strings', () {
      expect(constantTimeEqualString('hello', 'hello'), isTrue);
      expect(constantTimeEqualString('hello', 'world'), isFalse);
      expect(constantTimeEqualString('', ''), isTrue);
    });
  });
}
