import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kAccent = Color(0xFF00E5FF);
const kViolet = Color(0xFF7C4DFF);

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString('theme_mode');
    _mode = ThemeMode.values.firstWhere(
      (m) => m.name == v,
      orElse: () => ThemeMode.dark,
    );
    notifyListeners();
  }

  Future<void> set(ThemeMode m) async {
    _mode = m;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString('theme_mode', m.name);
  }
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: kViolet, brightness: b)
      .copyWith(primary: dark ? kAccent : kViolet);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: dark ? const Color(0xFF0A0E1A) : const Color(0xFFF4F7FF),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF0D1224) : Colors.white,
      indicatorColor: scheme.primary.withOpacity(0.18),
    ),
  );
}
