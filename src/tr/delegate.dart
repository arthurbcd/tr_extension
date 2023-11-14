part of '../tr_extension.dart';

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
