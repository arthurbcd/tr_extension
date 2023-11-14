part of '../tr_extension.dart';

///Mini [Tr] package for translation.
///
///Reads translations maps in the format {'locale': {'key': 'translation'}, ... }.
///
///- Changing Language:
///Translation.changeLanguage('pt').
///
///- Translating:
///For {'pt': {'login.button.title': 'Login'}}, just 'login.button.title'.tr -> 'Login'.
///
///- Dot Patterns:
///For {'pt': {'form.invalid': 'Invalid field'}}: 'form.invalid.email'.tr -> 'Invalid field'.
///
/// [.tr] Pattern: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
///
/// [.trn] Pattern: 'a.b.c' -> 'a.b' -> 'a' -> null.
class Tr {
  Tr._();
  static Tr? _instance;
  static final instance = _instance ??= Tr._();
  static Tr get to => instance;

  ///Path translations. Defaults to 'assets/translations'
  var _path = 'assets/translations';

  Locale? _locale; //current [Locale].
  var _fallback = const Locale('en', 'US');
  var _lazyLoad = false;
  var _logger = true;

  final Translations _translations = {};
  final TranslationsArgs _translationsArgs = {};

  /// All translations loaded.
  Translations get translations => Map.of(_translations);

  final _missingTranslations = <String>{};
  final _localizedFiles = <Locale, String>{};

  /// All currently missing translations.
  Set<String> get missingTranslations => Set.of(_missingTranslations);

  /// All supported [Locale] gotten from [_path] files or via [putTranslations].
  Set<Locale> get supportedLocales =>
      _translations.keys.map((e) => e.toLocale()).toSet();

  ///Load all locales from asset [path].
  Future<Set<Locale>> _loadLocales(String path) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final files = manifestMap.keys
        .where((key) => key.contains(path))
        .where((key) => key.endsWith('.json'));

    if (_logger && files.isNotEmpty) {
      dev.log('[Tr]: Translation files found: $files');
    } else if (_logger) {
      dev.log(
          '[Tr]: No translation files in $path. Did you declare this path on pubspec.yaml?');
    }

    for (final file in files) {
      final code = file.split('/').last.split('.').first; //fileName
      _localizedFiles[code.toLocale()] = file;
    }
    return supportedLocales;
  }

  /// Reload project json files. Useful for hot reload/reassemble.
  Future<void> reloadFiles() => _loadAll();

  ///Translation loader. Loads all if [_lazyLoad] = false.
  Future<void> _loadAll() async {
    await Future.wait(_localizedFiles.keys.map(_loadByLocale));
  }

  ///Translation loader. Loads one if [_lazyLoad] = true.
  Future<void> _loadByLocale(Locale locale) async {
    final file = _localizedFiles[locale];

    if (file == null) {
      if (_logger) {
        dev.log('[Tr]: Translation file not found for Locale: $locale');
      }
      return;
    }

    final map = jsonDecode(await rootBundle.loadString(file));
    putTranslations(locale, Map.from(map));
  }

  /// Puts new [Translations], overwriting existing ones.
  void putTranslations(Locale locale, Map<String, String> map) {
    _translations[locale.toString()] = map;
    _translationsArgs[locale.toString()] = _optimizeArgs(map);
  }

  /// Adds new [Translations], merging with existing ones.
  void addTranslations(Locale locale, Map<String, String> map) {
    assert(
      _translations.containsKey(locale.toString()),
      'Locale $locale not found. Use putTranslations() instead.',
    );
    _translations[locale.toString()]?.addAll(map);
    _translationsArgs[locale.toString()]?.addAll(_optimizeArgs(map));
  }

  Map<String, ArgReplacer> _optimizeArgs(Map<String, String> map) {
    final optimized = <String, ArgReplacer>{};

    map.forEach((key, value) {
      if (!key.contains('.{')) return;

      final regex = RegExp(r'\{.*?\}');
      final m1 = regex.allMatches(key).map((e) => e.group(0));
      final m2 = regex.allMatches(value).map((e) => e.group(0));

      if (!listEquals([...m1]..sort(), [...m2]..sort())) {
        if (_logger) dev.log('[Tr]: Invalid token replacement: $key -> $value');
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

  ///Translates [key]. Fallbacks to subkeys.
  String? translate(String key) {
    final keys = key.subWords('.');

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
        final args = keys.first.replaceFirst('$key.', '').split('.');
        final replaced = replacers[args.length]?.call(args);

        if (replaced != null) return replaced; //found.
      }

      final translation = _translations[code]?[key];
      if (translation != null) return translation; //found.
    }
    return null; //not found.
  }

  ///Current [locale].
  Locale get fallback => _fallback;
  Locale get locale => _locale ?? _fallback;

  ///Change app language with locale.
  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return; //ignoring.
    if (_logger) dev.log('[Tr]: Translation changed: $_locale -> $locale');
    _locale = locale;

    if (_logger && _lazyLoad) dev.log('[Tr]: isLazy = true. Loading...');
    if (_lazyLoad) await _loadByLocale(locale);
    if (_logger && _lazyLoad) dev.log('[Tr]: isLazy = true. Loaded!');

    //Refresh UI.
    _refreshApp?.call();
    // final context = Branvier.context?..visitAll(rebuild: true);

    if (_refreshApp == null && _logger) {
      dev.log('[Tr]: Currently running is read mode. In order to update the UI '
          'while changing language, set context.localizationsDelegates on MaterialApp');
    }

    //Log missing translations.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_logger) {
          final total = <String>{};
          final n = _missingTranslations.length;

          _translations.forEach((key, value) {
            total.addAll(value.values);
          });

          final percent = (1 - (n / total.length)) * 100;

          dev.log('[Tr]: There are $n missing keys. Progress: $percent%');
          dev.log('[Tr]: Missing keys: $_missingTranslations');
        }
      },
    );
  }

  ///Changes default path. Default: 'assets/translations'.
  static void setPath(String path) {
    if (to._logger) dev.log('[Tr]: Translation path: $path');
    to._path = path;
  }

  ///The [Locale] the app starts. If null, use system's or fallback.
  static void setInitial(Locale locale) {
    if (to._logger) dev.log('[Tr]: Translation initial locale: $locale');
    to._locale = locale;
  }

  ///Changes default fallback. Default: 'en_US'.
  static void setFallback(Locale locale) {
    if (to._logger) dev.log('[Tr]: Translation fallback: $locale');
    to._fallback = locale;
  }

  ///Activates or desactivate log messages.
  static void setLogger(bool isActive) {
    dev.log('[Tr]: Logger isActive: $isActive');
    to._logger = isActive;
  }

  ///If true, load translations files only when changeLanguage is used. Defaults to false.
  ///
  ///Tip: Only use in case you have lots of translations and huge files.
  static void setLazyLoad(bool isLazy) {
    if (to._logger) dev.log('[Tr]: Translation isLazy: $isLazy');
    to._lazyLoad = isLazy;
  }
}
