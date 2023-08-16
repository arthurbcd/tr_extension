library tr_extension;

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

typedef Translations = Map<String, Map<String, String>>;

VoidCallback? _refreshApp;

/// See: https://stackoverflow.com/a/58513635/3411681
void _rebuildAllChildren(BuildContext context) {
  void rebuild(Element el) {
    el.markNeedsBuild();
    el.visitChildren(rebuild);
  }

  (context as Element).visitChildren(rebuild);
}

extension TrInstall on BuildContext {
  ///Set this on [App].localizationsDelegates.
  LocalizationsDelegate get trDelegate {
    _refreshApp = () => _rebuildAllChildren(this);
    return const _TrDelegate();
  }

  ///Set this on [App].localizationsDelegates.
  List<LocalizationsDelegate> get localizationsDelegates {
    _refreshApp = () => _rebuildAllChildren(this);
    return [
      const _TrDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }
}

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

  ///All translations. {'locale': {'key': 'translation'}, ... }.
  final Translations translations = {};
  final missingTranslations = <String>{};
  final translationFiles = <String>{};
  final supportedLocales = <Locale>{};

  ///Load all locales from asset [path].
  Future<Set<Locale>> _loadLocales(String path) async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    translationFiles.clear();
    final files = manifestMap.keys
        .where((key) => key.contains(path))
        .where((key) => key.endsWith('.json'));
    translationFiles.addAll(files);

    supportedLocales.clear();
    for (final file in translationFiles) {
      final code = file.split('/').last.split('.').first; //fileName
      supportedLocales.add(code.toLocale());
    }
    return supportedLocales;
  }

  ///Translation loader. Loads one if [_lazyLoad] = true.
  Future<void> _loadByLocale(Locale locale) async {
    final translations = <String, Map<String, String>>{};
    late Locale fileLocale;

    final file = translationFiles.firstWhere((e) {
      fileLocale = e.split('/').last.split('.').first.toLocale();
      return fileLocale == locale;
    });

    final map = jsonDecode(await rootBundle.loadString(file));
    translations[fileLocale.toString()] = Map.from(map);

    ///Merge with existings.
    Tr.instance.translations.addAll(translations);
  }

  ///Translation loader. Loads all if [_lazyLoad] = false.
  Future<void> _loadAll() async {
    final translations = <String, Map<String, String>>{};

    for (final file in translationFiles) {
      final map = jsonDecode(await rootBundle.loadString(file));
      final locale = file.split('/').last.split('.').first.toLocale(); //file
      translations[locale.toString()] = Map.from(map);
    }

    ///Merge with existings.
    Tr.instance.translations.addAll(translations);
  }

  /// Reload project json files. Useful for hot reload/reassemble.
  Future<void> reloadFiles() => _loadAll();

  ///Translates [key]. Fallbacks to subkeys.
  String? translate(String key) {
    final keys = key.subWords('.');

    //checking locale.
    var code = locale.toString();
    final hasCode = translations.keys.contains(locale.toString());
    if (!hasCode) {
      final languages = translations.keys.where(
        (key) => key.startsWith(locale.languageCode),
      );
      if (languages.isNotEmpty) {
        code = languages.first;
      }
    }

    //looking for sub keys.
    for (final key in keys) {
      final translation = translations[code]?[key];
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
          final n = missingTranslations.length;

          translations.forEach((key, value) {
            total.addAll(value.values);
          });

          final percent = (1 - (n / total.length)) * 100;

          dev.log('[Tr]: There are $n missing keys. Progress: $percent%');
          dev.log('[Tr]: Missing keys: $missingTranslations');
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

class _TrDelegate extends LocalizationsDelegate {
  const _TrDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<Tr> load(Locale locale) async {
    final locales = await Tr.to._loadLocales(Tr.to._path);
    final hasLocale = locales.contains(locale);
    final localeToLoad = hasLocale ? locale : Tr.to._fallback;
    Tr.to._locale = Tr.to._locale ?? localeToLoad;

    if (!Tr.to._lazyLoad) {
      await Tr.to._loadAll();
    } else {
      await Tr.to._loadByLocale(Tr.to.locale);
    }

    return Tr.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}

extension TrExtension on String {
  ///Translates this key. Pattern: 'a.b.c' -> 'a.b' -> 'a' -> this.
  String get tr {
    final i = Tr.instance;
    if (i._logger && i.translations.isEmpty) {
      dev.log(
        '[Tr]: 0 translations. Did you set Tr.localizationDelegate(s) on MaterialApp?',
      );
    }
    final translation = trn;

    if (i._logger && translation == null) {
      dev.log('[Tr]: Missing translation: $this');
      i.missingTranslations.add(this);
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

///Auto translates this [key] if any translation matches.
class TrException implements Exception {
  TrException(this.key);
  final String key;
  String get message => key.tr;

  @override
  String toString() => message;
}
