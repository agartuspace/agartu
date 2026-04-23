import 'package:dio/dio.dart';
import '../models/quote_model.dart';

// retrofit-style service using Dio
class ApiService {
  static const _baseUrl = 'https://meowfacts.herokuapp.com';
  static const _timeout = Duration(seconds: 15);

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // interceptor for logging
    _dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false),
    );
  }

  Future<List<QuoteModel>> getQuotes({int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/',
      queryParameters: {'count': limit, 'lang': 'rus'},
    );

    final data = response.data;
    if (data == null) return [];

    final list = data['data'] as List<dynamic>? ?? [];
    return list.asMap().entries.map((e) {
      return QuoteModel(
        id: e.key,
        quote: e.value.toString(),
        author: 'Кошачий факт',
      );
    }).toList();
  }
}
