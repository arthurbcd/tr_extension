library tr_extension;

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
export 'package:tr_extension/tr_extension.dart';

part 'src/class.dart';
part 'src/delegate.dart';
part 'src/exception.dart';
part 'src/extension.dart';
part 'src/install.dart';

typedef Translations = Map<String, Map<String, String>>;
typedef TranslationsArgs = Map<String, Map<String, ArgReplacer>>;
typedef ArgReplacer = Map<int, String Function(List<String> args)>;
