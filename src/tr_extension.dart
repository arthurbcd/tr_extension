library tr_extension;

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

part 'tr/class.dart';
part 'tr/delegate.dart';
part 'tr/exception.dart';
part 'tr/extension.dart';
part 'tr/install.dart';

typedef Translations = Map<String, Map<String, String>>;
typedef TranslationsArgs = Map<String, Map<String, ArgReplacer>>;
typedef ArgReplacer = Map<int, String Function(List<String> args)>;
