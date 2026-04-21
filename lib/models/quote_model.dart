import 'package:flutter/foundation.dart';

@immutable
class QuoteModel {
  final int id;
  final String quote;
  final String author;

  const QuoteModel({
    required this.id,
    required this.quote,
    required this.author,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as int? ?? 0,
      quote: json['quote'] as String? ?? '',
      author: json['author'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'quote': quote, 'author': author};
  }
}
