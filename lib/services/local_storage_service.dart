import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  static const _keyTheme = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyUsername = 'username';

  LocalStorageService(this._prefs);

  // theme
  String get themeMode => _prefs.getString(_keyTheme) ?? 'system';
  Future<void> saveThemeMode(String mode) =>
      _prefs.setString(_keyTheme, mode);

  // locale
  String get locale => _prefs.getString(_keyLocale) ?? 'en';
  Future<void> saveLocale(String lang) =>
      _prefs.setString(_keyLocale, lang);

  // username
  String get username => _prefs.getString(_keyUsername) ?? '';
  Future<void> saveUsername(String name) =>
      _prefs.setString(_keyUsername, name);
}
