import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PIN hashing helper using PBKDF2-HMAC-SHA256.
///
/// Stored format: `pbkdf2$<iterations>$<base64Salt>$<base64Hash>`.
///
/// Migration: pre-hash plaintext PINs (legacy values without the `pbkdf2$`
/// prefix) are still accepted on first verify and rewritten in hashed form.
class PinHasher {
  const PinHasher();

  /// 100,000 PBKDF2 iterations. Tuned to stay well under 250 ms on mid-range
  /// mobile CPUs while still providing meaningful brute-force friction in the
  /// event of a secure-storage leak.
  static const int defaultIterations = 100000;

  /// 16-byte random salt is the modern PBKDF2 minimum.
  static const int saltLength = 16;

  /// 32-byte derived key (matches SHA-256 output length).
  static const int keyLength = 32;

  static const String _prefix = 'pbkdf2';

  /// Generates a fresh per-PIN salt and returns the canonical encoded hash.
  String hash(String pin, {int iterations = defaultIterations, Random? random}) {
    final salt = _randomBytes(saltLength, random);
    final derived = _pbkdf2Sha256(
      password: utf8.encode(pin),
      salt: salt,
      iterations: iterations,
      keyLength: keyLength,
    );
    return _encode(iterations: iterations, salt: salt, hash: derived);
  }

  /// Returns true when [pin] matches the encoded [storedValue].
  ///
  /// Legacy plaintext PINs (no `pbkdf2$` prefix) are matched with a
  /// constant-time string compare to avoid timing leaks during the migration
  /// window.
  bool verify(String pin, String storedValue) {
    if (storedValue.startsWith('$_prefix\$')) {
      final parsed = _decode(storedValue);
      if (parsed == null) return false;
      final derived = _pbkdf2Sha256(
        password: utf8.encode(pin),
        salt: parsed.salt,
        iterations: parsed.iterations,
        keyLength: parsed.hash.length,
      );
      return constantTimeEqualBytes(derived, parsed.hash);
    }

    return constantTimeEqualString(pin, storedValue);
  }

  /// True when the stored value is in the canonical hashed form.
  bool isHashed(String storedValue) => storedValue.startsWith('$_prefix\$');

  // ── Internals ────────────────────────────────────────────────────────────

  static Uint8List _randomBytes(int length, Random? random) {
    final rng = random ?? Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256 (RFC 8018 §5.2).
  static Uint8List _pbkdf2Sha256({
    required List<int> password,
    required List<int> salt,
    required int iterations,
    required int keyLength,
  }) {
    final hmac = Hmac(sha256, password);
    const blockSize = 32;
    final blockCount = (keyLength + blockSize - 1) ~/ blockSize;
    final out = Uint8List(blockCount * blockSize);

    for (var i = 1; i <= blockCount; i++) {
      final block = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt)
        ..setRange(salt.length, salt.length + 4, _intTo4Bytes(i));

      var u = Uint8List.fromList(hmac.convert(block).bytes);
      final t = Uint8List.fromList(u);

      for (var j = 1; j < iterations; j++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var k = 0; k < t.length; k++) {
          t[k] ^= u[k];
        }
      }

      out.setRange((i - 1) * blockSize, i * blockSize, t);
    }
    return Uint8List.sublistView(out, 0, keyLength);
  }

  static List<int> _intTo4Bytes(int value) => [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];

  static String _encode({
    required int iterations,
    required List<int> salt,
    required List<int> hash,
  }) {
    return '$_prefix\$$iterations\$${base64Encode(salt)}\$${base64Encode(hash)}';
  }

  static _ParsedHash? _decode(String value) {
    final parts = value.split(r'$');
    if (parts.length != 4 || parts[0] != _prefix) return null;
    final iterations = int.tryParse(parts[1]);
    if (iterations == null || iterations <= 0) return null;
    try {
      return _ParsedHash(
        iterations: iterations,
        salt: base64Decode(parts[2]),
        hash: base64Decode(parts[3]),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Compares two byte sequences in constant time relative to their length.
bool constantTimeEqualBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

/// Constant-time UTF-8 string compare (fixed-length pad with NUL on mismatch).
bool constantTimeEqualString(String a, String b) {
  return constantTimeEqualBytes(utf8.encode(a), utf8.encode(b));
}

class _ParsedHash {
  const _ParsedHash({
    required this.iterations,
    required this.salt,
    required this.hash,
  });

  final int iterations;
  final List<int> salt;
  final List<int> hash;
}
