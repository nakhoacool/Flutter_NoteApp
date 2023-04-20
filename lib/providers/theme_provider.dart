import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightTheme = ThemeData.light();
ThemeData darkTheme = ThemeData.dark();

class ThemeProvider extends ChangeNotifier {
  final String key = 'theme';
  bool _darkTheme = false;

  ThemeProvider() {
    _getThemeFromPref();
  }

  bool get darkTheme => _darkTheme;

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPref();
    notifyListeners();
  }

  Future<void> _getThemeFromPref() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _darkTheme = preferences.getBool(key) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPref() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(key, _darkTheme);
  }
}
