import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/api_repository.dart';
import 'api_state.dart';

class ApiCubit extends Cubit<ApiState> {
  final ApiRepository _repo;

  ApiCubit(this._repo) : super(const ApiInitial());

  Future<void> fetchQuotes() async {
    emit(const ApiLoading());
    try {
      final quotes = await _repo.fetchQuotes();
      emit(ApiLoaded(quotes));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }
}
