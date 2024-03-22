import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  final String _defaultLanguageCode = 'en'; // Default language code
  late Map<String, dynamic> _localizedStrings;

  // Singleton pattern
  static final LocalizationService _instance = LocalizationService._();

  LocalizationService._();

  static LocalizationService get instance => _instance;

  Future<void> loadLanguage(String languageCode) async {
    String jsonString = await rootBundle.loadString('locales/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String getString(String key) {
    return _localizedStrings[key] ?? key;
  }
}

