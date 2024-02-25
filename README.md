
# tr_extension

tr_extension is a no-InheritedWidget package designed to simplify the process of localization within your apps.

This package focus on achieving the simplest approach as possible, while being lightweight and straightforward.

## Getting started

### 1. Set-up your .json files

Put your `.json` files in the path: `assets/translations`.
Ex: 'pt_BR.json'. Separators allowed:_ , - , + , . , / , | , \ and space.

> The path can be changed within `TrDelegate` factory constructor.
> You can also use the extension `String.toLocale()`, available in this package.

### 2. Add the delagate and you are ready to go 🔥

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

> 'flutter_localizations' delegates are already included in [localizationDelegates]

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

## Dynamic Token Replacement

Super simplification of arguments and pluralization!

Suppose you have the json below:

```json
{
  "user.items.0": "You have zero items :(",
  "user.items.1": "You have exactly one item!",
  "user.items.{}": "You have {} items!", // positional
  "user.items.{}.{}": "{} have {} items!",
  "user.items.{a}.{b}.{c}": "{c} may {b} this {a}", // named
  "user.items.{c}.{}.{a}.{}": "I {} you {c} good {} the {a}", // mixed
  "user.items": "You have items!",
};
```

You can easily swap args in a smart combination of fallback matching:

```dart
  'user.items.0'.tr; // 'You have zero items :('
  'user.items.1'.tr; // 'You have exactly one item!'
  'user.items.${items.length}'.tr; // 'You have 2 items!'
  'user.items.${user.name}.${items.length}'.tr; // 'Arthur have 3 items!'
  'user.items.now.do.we'.tr; // 'we may do this now'
  'user.items.dancefloor.bet.look.on'.tr // 'I bet you look good on the dancefloor'
  'user.items'.tr; // 'You have items!'
```

Obs: You can't declare two keys with same args length. As the second one will override the first one, conflicting.

```json
  "user.items.{}.{}": ...,
  "user.items.{a}.{b}": ...,
```

## Instance methods

Use `TrDelegate.instance`.

```dart
///Changes the language with the chosen [Locale].
TrDelegate.setLocale(Locale locale) // or context.setLocale(Locale locale)

///Manually configures translations. Although we recommend using json files as described above.
TrDelegate.setTranslations(Locale locale, Map translations)
```

And the following getters:

```dart
TrDelegate.translations //all parsed translations
TrDelegate.missingTranslations //all missing translations
TrDelegate.translationFiles //all json files
TrDelegate.locale //the current locale
TrDelegate.supportedLocales  //all supported locales

```
