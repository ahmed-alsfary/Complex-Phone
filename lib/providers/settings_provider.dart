import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';

class SettingsProvider extends ChangeNotifier {
  static const _langKey = 'app_lang';
  static const _themeKey = 'app_theme_dark';

  AppLang lang = AppLang.ar;
  bool isDark = false;
  bool ready = false;

  S get s => S(lang);
  Locale get locale => Locale(lang.code);

  /// Material/Cupertino لا يدعمان الكردية — نستخدم العربية للـ framework مع الإبقاء على نصوص التطبيق بالكردية.
  Locale get materialLocale =>
      lang == AppLang.en ? const Locale('en') : const Locale('ar');

  TextDirection get textDirection =>
      lang.isRtl ? TextDirection.rtl : TextDirection.ltr;
  ThemeMode get themeMode => isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    lang = AppLangX.fromCode(prefs.getString(_langKey));
    isDark = prefs.getBool(_themeKey) ?? false;
    ready = true;
    notifyListeners();
  }

  Future<void> setLang(AppLang value) async {
    lang = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, value.code);
  }

  Future<void> toggleTheme() async {
    isDark = !isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<void> setDark(bool value) async {
    isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }
}
