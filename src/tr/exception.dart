part of '../tr_extension.dart';

///Auto translates this [key] if any translation matches.
class TrException implements Exception {
  TrException(this.key);
  final String key;
  String get message => key.tr;

  @override
  String toString() => message;
}
