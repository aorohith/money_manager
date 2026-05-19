import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/material_icon_resolver.dart';

void main() {
  group('MaterialIconResolver', () {
    test('returns matching const icon for known code point', () {
      final icon = MaterialIconResolver.fromCodePoint(
        Icons.savings_rounded.codePoint,
      );

      expect(icon, Icons.savings_rounded);
    });

    test('returns fallback icon for unknown code point', () {
      final icon = MaterialIconResolver.fromCodePoint(-1);

      expect(icon, MaterialIconResolver.fallback);
    });
  });
}
