part of '../tr_extension.dart';

/// Mini [TrDelegate] package for translation.
///
/// Reads translations maps in the format {'locale': {'key': 'translation'}, ... }.
///
/// - Changing Language:
/// context.changeLanguage('pt').
///
/// - Translating:
/// For {'pt': {'login.button.title': 'Login'}}, just 'login.button.title'.tr -> 'Login'.
///
/// - Dot Patterns:
/// For {'pt': {'form.invalid': 'Invalid field'}}: 'form.invalid.email'.tr -> 'Invalid field'.
///
/// [.tr] Pattern: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
///
/// [.trn] Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
///
class TrDelegate extends ListBase<LocalizationsDelegate>
    implements LocalizationsDelegate<TrDelegate> {
  /// The instance of [TrDelegate].
  static final instance = TrDelegate._();
  TrDelegate._();

  /// Configures the [TrDelegate].
  ///
  /// - [path]: The path to the translations files.
  /// - [log]: A function to log messages.
  /// - [reloadOnHotReload]: If true, reloads all translations on hot reload.
  /// - [alwaysUseUtcFormat]: If true, all date/time formats will be in UTC, ignoring the current locale.
  ///
  factory TrDelegate({
    String path = 'assets/translations',
    void Function(String message)? log = _defaultLogger,
    bool reloadOnHotReload = true,
    bool alwaysUseUtcFormat = false,
  }) {
    if (reloadOnHotReload && kDebugMode) {
      instance.reload(cache: false);
    }
    return instance
      .._path = path
      .._log = log
      .._alwaysUseUtcFormat = alwaysUseUtcFormat;
  }

  /// The default logger. Ex: `[tr]: message`.
  static _defaultLogger(String message) => dev.log(message, name: 'tr');

  // Configs.
  String _path = 'assets/translations';
  bool _alwaysUseUtcFormat = false;
  void Function(String message)? _log;
  void _print(String message) => _log?.call(message);

  // States.
  Locale? _locale;
  final Translations _translations = {};
  final TranslationsArgs _translationsArgs = {};
  final _missingTranslations = <String>{};
  final _localizedFiles = <Locale, String>{};

  /// The current [Locale].
  Locale get locale {
    assert(_locale != null, 'Locale not found. Did you set TrDelegate?');
    return _locale!;
  }

  /// All translations loaded.
  Translations get translations => Map.of(_translations);

  /// All currently missing translations.
  Set<String> get missingTranslations => Set.of(_missingTranslations);

  /// All supported [Locale] gotten from [_path] files or via [setTranslations].
  Set<Locale> get supportedLocales => _localizedFiles.keys.toSet();

  /// Whether the date/time format should always be in UTC.
  bool get alwaysUseUtcFormat => _alwaysUseUtcFormat;

  /// Puts new [Translations], overwriting existing ones.
  void setTranslations(Locale locale, Map<String, String> map) {
    _translations[locale.toString()] = map;
    _translationsArgs[locale.toString()] = _optimizeArgs(map);
  }

  /// Sets the [Locale], effectively changing the language of the app.
  ///
  /// If [locale] is null, it will use the system locale.
  Future<void> setLocale(Locale? locale) async {
    locale ??= Intl.systemLocale.toLocale();

    if (_locale == locale) return; //ignoring.
    _print('Translation changed: $_locale -> $locale');
    _locale = locale;
    Intl.defaultLocale = locale.toString();

    await reload();

    if (_log == null || !kDebugMode) return;
    Future(() {
      final total = <String>{};
      final n = _missingTranslations.length;

      _translations.forEach((key, value) {
        total.addAll(value.values);
      });

      final percent = (1 - (n / total.length)) * 100;

      _print('There are $n missing keys. Progress: $percent%');
      _print('Missing keys: $_missingTranslations');
    });
  }

  ///Translates [key]. Fallbacks to subkeys.
  String? translate(String key, {List<String>? args}) {
    final keys = key.subWords(RegExp(r'\.(?!\s)'));

    //checking locale.
    var code = locale.toString();
    final hasCode = _translations.keys.contains(locale.toString());
    if (!hasCode) {
      final languages = _translations.keys.where(
        (key) => key.startsWith(locale.languageCode),
      );
      if (languages.isNotEmpty) {
        code = languages.first;
      }
    }

    //looking for sub keys.
    for (final key in keys) {
      final replacers = _translationsArgs[code]?[key];

      if (replacers != null && keys.first != key) {
        args ??=
            keys.first.replaceFirst('$key.', '').split(RegExp(r'\.(?!\s)'));
        final replaced = replacers[args.length]?.call(args);

        if (replaced != null) return replaced; //found.
      }

      var translation = _translations[code]?[key];

      for (final arg in args ?? []) {
        translation = translation?.replaceFirst(RegExp(r'\{.*?\}'), arg);
      }

      if (translation != null) return translation; //found.
    }
    return null; //not found.
  }

  ///Load all locales from asset [path].
  Future<Set<Locale>> _loadLocales(String path) async {
    if (_localizedFiles.isNotEmpty) return supportedLocales;

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final files = manifestMap.keys
        .where((key) => key.startsWith(path) && key.endsWith('.json'));

    if (files.isNotEmpty) {
      _print('Translation files found: $files');
    } else {
      _print(
          'No translation files in $path. Did you declare this path on pubspec.yaml?');
    }

    for (final file in files) {
      final code = file.split('/').last.split('.').first; //fileName
      _localizedFiles[code.toLocale()] = file;
    }
    return supportedLocales;
  }

  ///Translation loader. Loads one if [_lazyLoad] = true.
  Future<void> _loadByLocale(Locale locale, {required bool cache}) async {
    final file = _localizedFiles[locale];

    if (file == null) {
      _print('Translation file not found for Locale: $locale');
      return;
    }

    final map = jsonDecode(await rootBundle.loadString(file, cache: cache));
    setTranslations(locale, Map.from(map));
  }

  Map<String, ArgReplacer> _optimizeArgs(Map<String, String> map) {
    final optimized = <String, ArgReplacer>{};

    map.forEach((key, value) {
      if (!key.contains('.{')) return;

      final regex = RegExp(r'\{.*?\}');
      final m1 = regex.allMatches(key).map((e) => e.group(0));
      final m2 = regex.allMatches(value).map((e) => e.group(0));

      if (!listEquals([...m1]..sort(), [...m2]..sort())) {
        _print('Invalid token replacement: $key -> $value');
        return;
      }

      final prefix = key.split('.{').first;

      String replacer(List<String> args) {
        final tokens = [...m1];
        String replaced = value;

        for (var arg in args) {
          replaced = replaced.replaceFirst(tokens.removeAt(0)!, arg);
        }
        return replaced;
      }

      optimized[prefix] ??= {};
      optimized[prefix]?[m1.length] = replacer;
    });

    return optimized;
  }

  var _reloading = false;

  /// Reloads all [Translations] of the current [locale].
  Future<void> reload({bool cache = true}) async {
    if (_reloading || _locale == null) return;
    _reloading = true;

    await _loadByLocale(_locale!, cache: cache)
        .then((_) => _refreshApp?.call())
        .whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reloading = false);
    });

    if (_refreshApp == null) {
      _print('Currently running is read mode. In order to update the UI '
          'while changing language, set context.locale on MaterialApp');
    } else {
      _print('$_locale translations reloaded.');
    }
  }

  @override
  Future<TrDelegate> load(Locale locale) async {
    if (_locale == locale) return this;

    final locales = await _loadLocales(_path);
    final hasLocale = locales.contains(_locale = locale);
    Intl.defaultLocale = locale.toString();

    if (hasLocale) {
      await _loadByLocale(locale, cache: true);
    }
    assert(
      hasLocale,
      '''Locale $locale not found in $_path
      
      Did you declare this path on pubspec.yaml?

      Make sure to set the supportedLocales on MaterialApp:

      MaterialApp(
        localizationsDelegates: TrDelegate(), // <- config
        locale: context.locale, <- current locale
        supportedLocales: const [
          Locale('en', 'US'), <- supported locales
          Locale('pt', 'BR'),
        ],
        home: const Home(),
      );

      Also, make sure it's in the right format:
      en_US.json -> Locale('en', 'US')
      pt-BR.json -> Locale('pt', 'BR')

      Supported separators:
      _ , - , + , . , / , | ,  and space.
      ''',
    );
    return this;
  }

  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(LocalizationsDelegate old) => false;

  @override
  Type get type => TrDelegate;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'LocalizationsDelegate')}[$type]';

  @override
  int get length => _delegates.length;

  @override
  set length(int newLength) => _delegates.length = newLength;

  @override
  operator [](int index) => _delegates[index];

  @override
  void operator []=(int index, value) => _delegates[index] = value;

  late final _delegates = <LocalizationsDelegate>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    this,
  ];
}
