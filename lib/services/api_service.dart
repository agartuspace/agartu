import 'package:dio/dio.dart';
import '../models/quote_model.dart';

// retrofit-style service using Dio
class ApiService {
  static const _baseUrl = 'https://dummyjson.com';
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

  // GET /quotes?limit=20
  Future<List<QuoteModel>> getQuotes({int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/quotes',
      queryParameters: {'limit': limit},
    );

    final data = response.data;
    if (data == null) return [];

    final list = data['quotes'] as List<dynamic>? ?? [];
    return list
        .map((e) => QuoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
