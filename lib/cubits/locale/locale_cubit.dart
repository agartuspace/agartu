import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/local_storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final LocalStorageService _storage;

  LocaleCubit(this._storage)
      : super(Locale(_storage.locale));

  Future<void> changeLocale(BuildContext context, String langCode) async {
    await _storage.saveLocale(langCode);
    await context.setLocale(Locale(langCode));
    emit(Locale(langCode));
  }
}
