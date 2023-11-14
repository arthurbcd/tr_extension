part of '../tr_extension.dart';

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
