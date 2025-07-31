// lib/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default tema adalah Light

  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadThemeFromPrefs(); // Muat tema saat service diinisialisasi
  }

  // Mengganti tema (light <-> dark)
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToPrefs(_themeMode); // Simpan pilihan tema
    notifyListeners(); // Beri tahu widget yang mendengarkan
  }

  // Memuat tema dari SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode =
        prefs.getBool('isDarkMode') ?? false; // Default false (light)
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Menyimpan tema ke SharedPreferences
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', mode == ThemeMode.dark);
  }
}
