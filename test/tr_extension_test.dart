import 'package:flutter_test/flutter_test.dart';

import 'package:tr_extension/tr_extension.dart';

void main() {
  group('strings', () {
    test('subWords', () {
      const words = '1.2.3.4.5';
      final subwords = words.subWords('.');

      expect(subwords.length, 5);
      expect(subwords.first, words);
      expect(subwords.last, '1');
    });

    String tr() {
      const words = '1.2.3.4.5';
      final subwords = words.subWords('.');

      for (final word in subwords) {
        final translation = word == '';
        if (translation) return word;
      }
      return words;
    }

    test('tr', () {
      expect(tr(), '1.2.3.4.5');
    });

    test('tr', () {
      expect(tr(), '1.2.3.4.5');
    });
  });

  group('toLocale()', () {
    test('should return Locale _ object with two parts', () {
      final locale = 'en_US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale | object with two parts', () {
      final locale = 'en|US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale . object with two parts', () {
      final locale = 'en.US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale - object with two parts', () {
      final locale = 'en-US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale /s object with two parts', () {
      final locale = 'en US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale / object with two parts', () {
      final locale = 'en/US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale + object with two parts', () {
      final locale = 'en/US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale slash object with two parts ', () {
      final locale = r'en\US'.toLocale();
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
    });

    test('should return Locale object with one part', () {
      final locale = 'fr'.toLocale();
      expect(locale.languageCode, equals('fr'));
      expect(locale.countryCode, isNull);
    });
  });
}
