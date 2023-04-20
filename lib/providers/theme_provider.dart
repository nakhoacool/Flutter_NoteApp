import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightTheme = ThemeData.light();
ThemeData darkTheme = ThemeData.dark();

class ThemeProvider extends ChangeNotifier {
  final String key = 'theme';
  late SharedPreferences preferences;
  late bool _darkTheme;

  ThemeProvider() {
    _initPref();
    _darkTheme = false;
    _getThemeFromPref();
  }

  bool get darkTheme => _darkTheme;

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPref();
    notifyListeners();
  }

  Future<void> _initPref() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> _getThemeFromPref() async {
    _darkTheme = preferences.getBool(key) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPref() async {
    preferences.setBool(key, _darkTheme);
  }
}
