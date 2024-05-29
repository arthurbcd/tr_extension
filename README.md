
# tr_extension

Tr Extension is a smart and lightweight string translation through extension.

## Features

- 🛠️ Simplified Setup: No widgets. Few lines, and you're done!
- ↩️ Fallback Pattern: Smart key matching. Be specific or generic.
- 🔀 Argument Replacement: Empower your JSON. Handle plurals & arguments.
- 🔄 Locale Auto-Sync: Set Locale. Reflect changes.
- 🌍 Flutter Integration. Works with sdk widgets and flutter_localizations.
- ⚡️ Hot-reload friendly: Update your translations without restarting your app.

## Getting started 🔥

### Setup files

Add `tr_extension` to your `pubspec.yaml`:

```yaml
dependencies:
  tr_extension: ^0.5.1
```

Add your translations folder path in your `pubspec.yaml`:

```yaml
flutter:
  assets:
     - assets/translations/ #default
```

> Note: When changing the path, you must also change the path in the `TrDelegate` factory constructor, and recompile the app.

Put your `.json` files in the folder with the name of the locale.

- `assets/translations/en_US.json`.
- `assets/translations/pt-BR.json`.

> Separators allowed:_ , - , + , . , / , | , \ and space.

Each file should contain a map of key/value pairs. Where the key is the translation key and the value is the translation itself.

```json
{
  "hello_world": "Hello World!"
}
```

> The path can be changed within `TrDelegate` factory constructor.

### Setup app

```dart
MaterialApp(
  localizationsDelegates: TrDelegate(path: ...).toList(), // <- includes flutter_localizations
  locale: context.locale, // <- auto state management
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('pt', 'BR'),
  ],
  home: const Home(),
);
```

> 'flutter_localizations' delegates are included in `.toList()`.

## Usage

Add '.tr' or '.trn' on any String and it will replace with the respective key/value from your translations. Where:

- tr: returns the same string key when not found.
- trn: returns null when not found.

```dart
    Text('helloWorld'.tr); // print -> 'Hello World!'
    Text('helloUniverse'.trn ?? 'other'); // print -> 'other'
```

## Fallback Pattern

The fallback pattern will first try to translate the whole string, if not found, it will atempt to look for the next fallback pattern:

- [.tr]: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
- [.trn]: 'a.b.c' -> 'a.b' -> 'a' -> null.

For the below translations:

```json
{
  "form.invalid": "This field in invalid",
  "form.invalid.email": "Invalid email",
};
```

Will return:

```dart
'form.invalid.email'.tr // 'Invalid email'.
'form.invalid.name'.tr // 'This field in invalid'.
'form.invalid'.tr // 'This field in invalid'.
```

## Argument Replacement

Super simplification of arguments and pluralization!

Suppose you have the json below:

```json
{
    "user_title.{name}.male": "{name} is nominated for Best Actor",
    "user_title.{name}.female": "{name} is nominated for Best Actress",
    "user_title.{name}": "{name} is nominated for Best Actor/Actress",
    "user_description.male": "He is the favorite this year!",
    "user_description.female": "She is the favorite this year!",
    "user_description": "They are the favorite this year!",
    "user_oscars.{name}.0": "{name} still hasn't won an Oscar.",
    "user_oscars.{name}.1": "This is {name}'s first Oscar!",
    "user_oscars.{name}.{}": "{name} has won {} Oscars"
}
```

You can easily swap args in a smart combination of fallback matching:

```dart
  final name = 'Emma Stone';
  final gender = 'female';
  final oscars = 1;

  print('user_title.$name.$gender'.tr); // 'Emma Stone is nominated for Best Actress'
  print('user_description.$gender'.tr); // 'She is the favorite this year!'
  print('user_oscars.$name.$oscars'.tr); // 'This is Emma Stone's first Oscar!'
```

## Instance methods

Use `TrDelegate.instance` or `Localizations.of<TrDelegate>(context, TrDelegate)` to get the instance of the delegate.

```dart
///Changes the language with the chosen [Locale].
.setLocale(Locale locale) // or context.setLocale(Locale locale)

///Manually configures translations. Although we recommend using json files as described above.
.setTranslations(Locale locale, Map translations)
```

And the following getters:

```dart
.translations //all parsed translations
.missingTranslations //all missing translations
.translationFiles //all json files
.locale //the current locale
.supportedLocales  //all supported locales

```
