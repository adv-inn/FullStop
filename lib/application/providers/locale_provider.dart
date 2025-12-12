import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'app_locale';

/// Supported locales in the app
class SupportedLocales {
  static const Locale english = Locale('en');
  static const Locale chinese = Locale('zh');
  static const Locale japanese = Locale('ja');

  static const List<Locale> all = [english, chinese, japanese];

  /// Returns null for system default
  static Locale? fromLanguageCode(String? code) {
    if (code == null) return null;
    switch (code) {
      case 'en':
        return english;
      case 'zh':
        return chinese;
      case 'ja':
        return japanese;
      default:
        return null;
    }
  }
}

/// Notifier for managing locale settings
/// null means use system default
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_localeKey);
      if (savedCode != null) {
        state = SupportedLocales.fromLanguageCode(savedCode);
      }
    } catch (e) {
      // Ignore errors, use system default
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale != null) {
        await prefs.setString(_localeKey, locale.languageCode);
      } else {
        await prefs.remove(_localeKey);
      }
    } catch (e) {
      // Ignore save errors
    }
  }

  void setSystemDefault() => setLocale(null);
  void setEnglish() => setLocale(SupportedLocales.english);
  void setChinese() => setLocale(SupportedLocales.chinese);
  void setJapanese() => setLocale(SupportedLocales.japanese);
}

/// Provider for locale management
/// Returns null for system default, or a specific Locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
