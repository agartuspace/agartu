import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final LocalStorageService _storage;

  ThemeCubit(this._storage) : super(_fromString(_storage.themeMode));

  Future<void> setLight() async {
    await _storage.saveThemeMode('light');
    emit(ThemeMode.light);
  }

  Future<void> setDark() async {
    await _storage.saveThemeMode('dark');
    emit(ThemeMode.dark);
  }

  Future<void> setSystem() async {
    await _storage.saveThemeMode('system');
    emit(ThemeMode.system);
  }

  static ThemeMode _fromString(String s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
