# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.9.2 - Apr 01, 2025

- Fix `TrDelegate.path` conflicts with external packages.

## 0.9.1 - Fev 05, 2025

- Force args translation when manually set.

## 0.9.0 - Fev 04, 2025

- Added `args` parameter to `TrDelegate.translate`.
- Added `trArgs/trnArgs` String extension to manually pass arguments.

## 0.8.0 - Jan 30, 2025

- Now you can setup `TrDelegate` as a list or element.
- Added `context.tr` to access `TrDelegate`.
- Added `context.supportedLocales` to access supported locales.
- Now `setLocate` accepts nullable locale. Setting null will use system's locale.
- Now `Tr.instance.locale` is non-nullable.
- Remove `dart:collection` dependency.
- Bump Flutter SDK to 3.0.0.

## 0.7.1 - Nov 22, 2024

- Expose cache in TrDelegate.reload.

## 0.7.0 - Nov 11, 2024

- Now it's possible to await BuildContext.setLocale.
- Improved loading in case the same locale is set.
- Improved reloading on hot reload.

## 0.6.1 - Jun 06, 2024

- Added `TrDelegate.alwaysUseUtcFormat`.

## 0.6.0 - May 29, 2024

- Added `Intl.defaultLocale` integration.
- Added `DateTime` extensions for `DateFormat`
- Added `String` extensions for `NumberFormat`.

## 0.5.2 - Apr 30, 2024

- Fixed conflicts when using '.' inside the translation argument.

Thanks to `suamirochadev` for pointing this out.

## 0.5.1 - Feb 25, 2024

- Updated README.

## 0.5.0 - Feb 24, 2024

- Complete rewrite of the package setup configuration.
- The package is now completely compatible with `Localizations` and `MaterialApp` widgets.
- Removed `Tr` class and all it's static methods.
- Added `TrDelegate` factory constructor for configuration.
- Added `toList()` to `TrDelegate` to include flutter localization delegate.
- Added `context.locale` for state management.
- Updated tests.
- Updated README.
- Updated example.

## 0.1.2 - Nov 14, 2023

- Added example

## 0.1.1 - Nov 14, 2023

- Updated README

## 0.1.0 - Nov 14, 2023

- Added Dynamic Token Replacement feature.
- Added Tr.to.putTranslations
- Added Tr.to.addTranslations
- Added invalid token warning log.
- Added pubspec.yaml asset warning log.
- Optimized code for hash mapped querying.
- Optimized translations loading.
- Updated tests.

## 0.0.2 - Aug 16, 2023

### Changed

- Bump Flutter SDK to 2.17.0 (flutter 3.0).

## 0.0.1 - Aug 12, 2023

### Added

- Initial pre-release.
