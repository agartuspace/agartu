import 'package:equatable/equatable.dart';
import '../../models/quote_model.dart';

sealed class ApiState extends Equatable {
  const ApiState();

  @override
  List<Object?> get props => [];
}

final class ApiInitial extends ApiState {
  const ApiInitial();
}

final class ApiLoading extends ApiState {
  const ApiLoading();
}

final class ApiLoaded extends ApiState {
  final List<QuoteModel> quotes;
  const ApiLoaded(this.quotes);

  @override
  List<Object?> get props => [quotes];
}

final class ApiError extends ApiState {
  final String message;
  const ApiError(this.message);

  @override
  List<Object?> get props => [message];
}
