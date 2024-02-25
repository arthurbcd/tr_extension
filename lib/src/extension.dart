part of '../tr_extension.dart';

extension TrExtension on String {
  ///Translates this key. Pattern: 'a.b.c' -> 'a.b' -> 'a' -> this.
  String get tr {
    final i = TrDelegate.instance;
    final translation = trn;

    if (translation == null) {
      i._print('[Tr]: Missing translation: $this');
      i.missingTranslations.add(this);
    }

    return translation ?? this;
  }

  ///Translates this key. Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
  String? get trn => TrDelegate.instance.translate(this);

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

VoidCallback? _refreshApp;

extension TrContextExtension on BuildContext {
  /// Change the language of the app, and sets the new locale.
  void setLocale(Locale locale) {
    final delegate = Localizations.of<TrDelegate>(this, TrDelegate);
    assert(delegate != null, '''
    TrDelegate not found. Did you set TrDelegate on MaterialApp.localizationDelegates?
    ''');

    delegate?.setLocale(locale);
  }

  /// Same as [Localizations.maybeLocaleOf].
  ///
  /// Setting this on [MaterialApp.locale] automatically enables state
  /// management on [setLocale].
  Locale? get locale {
    final locale = Localizations.maybeLocaleOf(this);
    if (locale != null) {
      return locale;
    }

    // we capture only the context above the [MaterialApp]
    _refreshApp = _rebuildAllChildren;
    return TrDelegate.instance._locale;
  }

  /// See: https://stackoverflow.com/a/58513635/3411681
  void _rebuildAllChildren() {
    if (!mounted) return;

    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (this as Element).markNeedsBuild();
    visitChildElements(rebuild);
  }
}
