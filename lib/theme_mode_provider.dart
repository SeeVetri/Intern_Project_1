import 'package:flutter/material.dart';

enum ThemeModeType { light, dark }

class ThemeModeProvider extends ChangeNotifier {
  ThemeModeType _themeMode = ThemeModeType.light;

  ThemeModeType get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeModeType.light
        ? ThemeModeType.dark
        : ThemeModeType.light;
    notifyListeners();
  }
}
