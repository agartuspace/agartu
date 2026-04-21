import '../models/quote_model.dart';
import '../services/api_service.dart';

class ApiRepository {
  final ApiService _service;

  ApiRepository({ApiService? service}) : _service = service ?? ApiService();

  Future<List<QuoteModel>> fetchQuotes() => _service.getQuotes(limit: 20);
}
