part of '../tr_extension.dart';

extension TrExtension on String {
  ///Translates this key. Pattern: 'a.b.c' -> 'a.b' -> 'a' -> this.
  String get tr {
    final i = Tr.instance;
    if (i._logger && i._translations.isEmpty) {
      dev.log(
        '[Tr]: 0 translations. Did you set Tr.localizationDelegate(s) on MaterialApp?',
      );
    }
    final translation = trn;

    if (i._logger && translation == null) {
      dev.log('[Tr]: Missing translation: $this');
      i._missingTranslations.add(this);
    }

    return translation ?? this;
  }

  ///Translates this key. Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
  String? get trn => Tr.to.translate(this);

  ///Converts this String to [Locale]. Separators: _ , - , + , . , / , | , \ and space.
  Locale toLocale() {
    final parts = split(RegExp(r'[_\-\s\.\/|+\\]'));
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else if (parts.length == 1) {
      return Locale(parts[0]);
    } else {
      dev.log('[Tr]: invalid Locale: $this');
      return Locale(this);
    }
  }

  ///All sub words between [pattern]. Ex: 'a.b.c' -> ['a.b.c','a.b','a'].
  List<String> subWords(Pattern pattern) {
    final words = split(pattern);
    final nestedStrings = <String>[];

    for (var i = 0; i < words.length; i++) {
      final currentNestedString = words.sublist(0, i + 1).join('.');
      nestedStrings.add(currentNestedString);
    }

    return nestedStrings.reversed.toList();
  } //tested [string_test]
}
