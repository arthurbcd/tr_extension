// ignore_for_file: non_constant_identifier_names

part of '../tr_extension.dart';

extension TrExtension on String {
  ///Translates this key. Pattern: 'a.b.c' -> 'a.b' -> 'a' -> this.
  String get tr {
    final i = TrDelegate.instance;
    final translation = trn;

    if (translation == null) {
      i._print('Missing translation: $this');
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
      dev.log('Invalid Locale: $this');
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
  Future<void> setLocale(Locale locale) async {
    final delegate = Localizations.of<TrDelegate>(this, TrDelegate);
    assert(delegate != null, '''
    TrDelegate not found. Did you set TrDelegate on MaterialApp.localizationDelegates?
    ''');

    await delegate?.setLocale(locale);
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

extension TrDateTimeExtension on DateTime {
  /// Formats this [DateTime] to a string using [locale] and [format].
  ///
  /// - s - Seconds.
  /// - m - Minutes.
  /// - j - Hours.
  /// - d - Day.
  /// - E - Weekday.
  /// - M - Month.
  /// - y - Year.
  String format([
    String? format,
    Locale? locale,
  ]) {
    final date = TrDelegate.instance.alwaysUseUtcFormat ? toUtc() : toLocal();
    return DateFormat(format, locale?.toString()).format(date);
  }

  String d([Locale? locale]) => format('d', locale);
  String E([Locale? locale]) => format('E', locale);
  String EEEE([Locale? locale]) => format('EEEE', locale);
  String LLL([Locale? locale]) => format('LLL', locale);
  String LLLL([Locale? locale]) => format('LLLL', locale);
  String M([Locale? locale]) => format('M', locale);
  String Md([Locale? locale]) => format('Md', locale);
  String MEd([Locale? locale]) => format('MEd', locale);
  String MMM([Locale? locale]) => format('MMM', locale);
  String MMMd([Locale? locale]) => format('MMMd', locale);
  String MMMEd([Locale? locale]) => format('MMMEd', locale);
  String MMMM([Locale? locale]) => format('MMMM', locale);
  String MMMMd([Locale? locale]) => format('MMMMd', locale);
  String MMMMEEEEd([Locale? locale]) => format('MMMMEEEEd', locale);
  String QQQ([Locale? locale]) => format('QQQ', locale);
  String QQQQ([Locale? locale]) => format('QQQQ', locale);
  String y([Locale? locale]) => format('y', locale);
  String yM([Locale? locale]) => format('yM', locale);
  String yMd([Locale? locale]) => format('yMd', locale);
  String yMEd([Locale? locale]) => format('yMEd', locale);
  String yMMM([Locale? locale]) => format('yMMM', locale);
  String yMMMd([Locale? locale]) => format('yMMMd', locale);
  String yMMMEd([Locale? locale]) => format('yMMMEd', locale);
  String yMMMM([Locale? locale]) => format('yMMMM', locale);
  String yMMMMd([Locale? locale]) => format('yMMMMd', locale);
  String yMMMMEEEEd([Locale? locale]) => format('yMMMMEEEEd', locale);
  String yQQQ([Locale? locale]) => format('yQQQ', locale);
  String yQQQQ([Locale? locale]) => format('yQQQQ', locale);
  String H([Locale? locale]) => format('H', locale);
  String Hm([Locale? locale]) => format('Hm', locale);
  String Hms([Locale? locale]) => format('Hms', locale);
  String j([Locale? locale]) => format('j', locale);
  String jm([Locale? locale]) => format('jm', locale);
  String jms([Locale? locale]) => format('jms', locale);
}

extension TrNumberStringExtension on String {
  /// e.g. "1.2M" instead of "1,200,000".
  String compact({
    Locale? locale,
    bool explicitSign = false,
  }) {
    return NumberFormat.compact(
      locale: locale?.toString(),
      explicitSign: explicitSign,
    ).format(num.tryParse(this));
  }

  /// e.g. "USD1.2M" instead of "$1,200,000".
  String compactCurrency({
    Locale? locale,
    String? name,
    String? symbol,
    int? decimalDigits,
  }) {
    return NumberFormat.compactCurrency(
      locale: locale?.toString(),
      name: name,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(num.tryParse(this));
  }

  /// e.g. "1.2 million" instead of "1,200,000".
  String compactLong({
    Locale? locale,
    bool explicitSign = false,
  }) {
    return NumberFormat.compactLong(
      locale: locale?.toString(),
      explicitSign: explicitSign,
    ).format(num.tryParse(this));
  }

  /// e.g. "$1.2M" instead of "$1,200,000".
  String compactSimpleCurrency({
    Locale? locale,
    String? name,
    int? decimalDigits,
  }) {
    return NumberFormat.compactSimpleCurrency(
      locale: locale?.toString(),
      name: name,
      decimalDigits: decimalDigits,
    ).format(num.tryParse(this));
  }

  /// e.g. "USD1,200,000" for "1200000".
  String currency({
    Locale? locale,
    String? name,
    String? symbol,
    int? decimalDigits,
    String? customPattern,
  }) {
    return NumberFormat.currency(
      locale: locale?.toString(),
      name: name,
      symbol: symbol,
      decimalDigits: decimalDigits,
      customPattern: customPattern,
    ).format(num.tryParse(this));
  }

  /// e.g. "$1,200,000" for 1200000.
  String simpleCurrency({
    Locale? locale,
    String? name,
    int? decimalDigits,
  }) {
    return NumberFormat.simpleCurrency(
      locale: locale?.toString(),
      name: name,
      decimalDigits: decimalDigits,
    ).format(num.tryParse(this));
  }

  /// e.g. "1,200" for 1200.
  String decimalPattern([
    Locale? locale,
  ]) {
    return NumberFormat.decimalPattern(
      locale?.toString(),
    ).format(num.tryParse(this));
  }

  /// e.g. "120,000%" for 1200.
  String percentPattern([Locale? locale]) {
    return NumberFormat.percentPattern(
      locale?.toString(),
    ).format(num.tryParse(this));
  }

  /// e.g. "1.2E6" for 1200000.
  String scientificPattern([Locale? locale]) {
    return NumberFormat.scientificPattern(
      locale?.toString(),
    ).format(num.tryParse(this));
  }
}
