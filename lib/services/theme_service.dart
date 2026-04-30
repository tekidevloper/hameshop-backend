import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // Singleton pattern
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Current theme mode
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

  // Load theme preference from storage
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0; // 0 = system, 1 = light, 2 = dark
    themeMode.value = ThemeMode.values[themeModeIndex];
  }

  // Update and save theme preference
  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }
}
