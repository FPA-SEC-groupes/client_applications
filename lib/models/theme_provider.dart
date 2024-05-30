import 'package:flutter/material.dart';
import 'package:hello_way_client/utils/secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  final SecureStorage secureStorage = SecureStorage();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadThemePreference();
  }

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    saveThemePreference();
    notifyListeners();
  }

  Future<void> loadThemePreference() async {
    String? themeString = await secureStorage.readData('themeMode');
    _isDarkMode = themeString == "dark";
    notifyListeners();
  }

  Future<void> saveThemePreference() async {
    await secureStorage.writeData('themeMode', _isDarkMode ? 'dark' : 'light');
  }
}
