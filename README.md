
# tr_extension

tr_extension is a no-InheritedWidget package designed to simplify the process of localization within your apps.
What sets this package apart is its no-InheritedWidget approach, making integration seamless and allowing developers to encapsulate packages into services with ease.

## Features

## Getting started

### 1. Set-up your .json files

Put your `.json` files in the path: `assets/translations`.
Ex: 'pt_BR.json'. Separators allowed: _ , - , + , . , / , | , \ and space.

> The path can be changed with `Tr.setPath()`.
> You can also use the extension `String.toLocale()`, available in this package.

### 2. Add the delagate and you are ready to go 🔥

```dart
MaterialApp(
    //with flutter_localizations
    localizationDelegates: context.localizationDelegates,
    //or just [context.trDelegate]
    localizationDelegates: [context.trDelegate, ...others],
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

A Dot Pattern was added for smart fallback translation.

For the below translations:
`{'pt': {'form.invalid': 'Invalid field'}}`

Will return:
'form.invalid.email'.tr -> 'Invalid field'.

The pattern fallback:
[.tr]: 'a.b.c' -> 'a.b' -> 'a' -> 'a.b.c'.
[.trn]: 'a.b.c' -> 'a.b' -> 'a' -> null.

### Control

Use `Tr.to` to access the static instance of `Tr`

```dart

///Translates the desired key.
Tr.to.translate(String key)

///Changes the language with the chosen [Locale].
Tr.to.changeLanguage(Locale locale)

///Reloads all json files again, useful for reassembling (hot reload).
Tr.to.reloadFiles()

```

And the following getters:

```dart
Tr.to.translations //all parsed translations
Tr.to.missingTranslations //all missing translations
Tr.to.translationFiles //all json files
Tr.to.locale //the current locale
Tr.to.fallback //the fallback locale
Tr.to.supportedLocales  //all supported locales

```

### Additional information

Aditionally you can use some static methods for configuration:

```dart
  ///Changes default path. Default: 'assets/translations'.
  Tr.setPath(String path)

  ///The [Locale] the app starts. If null, use system's or fallback.
  Tr.setInitial(Locale locale)

  ///Changes default fallback. Default: 'en_US'.
  Tr.setFallback(Locale locale)

  ///Activates or desactivate log messages.
  Tr.setLogger(bool isActive)

  ///If true, load translations files only when changeLanguage is used. Defaults to false.
  Tr.setLazyLoad(bool isLazy)
```
