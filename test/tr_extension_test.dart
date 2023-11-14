import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import '../src/tr_extension.dart';

void main() {
  group('strings', () {
    test('Fallback Pattern', () {
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

    test('Dynamic Token Replacement', () {
      final keys = {
        'user.items.0': 'You have zero items :(',
        'user.items.1': 'You have exactly one item!',
        'user.items.{}': 'You have {} items!',
        'user.items.{}.{}': '{} have {} items!',
        'user.items.{a}.{b}.{c}': '{c} may {b} this {a}',
        'user.items.{c}.{}.{a}.{}': 'I {} you {c} good {} the {a}',
        'user.items': 'You have items!',
      };

      Tr.to.putTranslations(const Locale('en'), keys);

      final items = Tr.to.translate('user.items.0');
      expect(items, 'You have zero items :(');

      final item = Tr.to.translate('user.items.1');
      expect(item, 'You have exactly one item!');

      final item2 = Tr.to.translate('user.items.2');
      expect(item2, 'You have 2 items!');

      final item3 = Tr.to.translate('user.items.Art.3');
      expect(item3, 'Art have 3 items!');

      final item4 = Tr.to.translate('user.items.now.do.we');
      expect(item4, 'we may do this now');

      final item5 = Tr.to.translate('user.items.look.bet.dancefloor.on');
      expect(item5, 'I bet you look good on the dancefloor');

      final item6 = Tr.to.translate('user.items');
      expect(item6, 'You have items!');
    });
  });

  //TODO: translate named args

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
