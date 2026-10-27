import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

/// Interface abstrata para busca de obras (permite substituição por fake nos testes).
abstract class BooksApiService {
  /// Pesquisa obras pelo [query] informado.
  /// O [filter] pode ser 'all' (padrão), 'title' ou 'author'.
  Future<List<BookModel>> search(String query, {String filter = 'all'});
}

/// Implementação que consulta a Google Books API v1.
///
/// Atende: RF-03, RF-04, RNF-05, RNF-06, CA-02.
class GoogleBooksApiService implements BooksApiService {
  final http.Client _client;
  final String _apiKey;

  GoogleBooksApiService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = (apiKey ?? const String.fromEnvironment('GOOGLE_BOOKS_API_KEY'))
          .trim();

  @override
  Future<List<BookModel>> search(String query, {String filter = 'all'}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final q = _buildQuery(trimmed, filter);

    final parameters = <String, String>{
      'q': q,
      'maxResults': '20',
      'printType': 'books',
    };
    if (_apiKey.isNotEmpty) {
      parameters['key'] = _apiKey;
    }

    final uri = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      parameters,
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 429) {
        _logRateLimitDiagnostics(response);
        throw Exception(
          'O catálogo está recebendo muitas buscas no momento. '
          'Aguarde um pouco e tente novamente.',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Erro ao consultar o catálogo (HTTP ${response.statusCode}). Tente novamente.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Resposta inválida do catálogo.');
      }

      final items = decoded['items'];
      if (items == null || items is! List) return [];

      return items
          .whereType<Map>()
          .map((item) => _parseVolume(Map<String, dynamic>.from(item)))
          .where((book) => book.googleBooksId.isNotEmpty)
          .toList();
    } on SocketException {
      throw Exception(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on TimeoutException {
      throw Exception(
        'A busca demorou muito. Verifique sua conexão e tente novamente.',
      );
    } on http.ClientException {
      throw Exception(
        'Não foi possível acessar o catálogo. Verifique sua conexão e tente novamente.',
      );
    } on FormatException {
      throw Exception(
        'O catálogo retornou uma resposta inválida. Tente novamente mais tarde.',
      );
    }
  }

  void _logRateLimitDiagnostics(http.Response response) {
    if (!kDebugMode) return;

    Map<String, dynamic> error;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['error'] is! Map) {
        debugPrint(
          'Google Books API diagnostic: HTTP 429 sem campos error válidos.',
        );
        return;
      }
      error = Map<String, dynamic>.from(decoded['error'] as Map);
    } on FormatException {
      debugPrint('Google Books API diagnostic: HTTP 429 com JSON inválido.');
      return;
    }

    final diagnosticFields = <String>['HTTP ${response.statusCode}'];
    final code = error['code'];
    if (code is num || code is String) {
      diagnosticFields.add('error.code: ${_sanitizeDiagnosticValue('$code')}');
    }

    final message = error['message'];
    if (message is String) {
      diagnosticFields.add(
        'error.message: ${_sanitizeDiagnosticValue(message)}',
      );
    }

    final errors = error['errors'];
    if (errors is List) {
      for (final item in errors) {
        if (item is Map && item['reason'] is String) {
          diagnosticFields.add(
            'error.errors[].reason: '
            '${_sanitizeDiagnosticValue(item['reason'] as String)}',
          );
        }
      }
    }

    debugPrint('Google Books API diagnostic: ${diagnosticFields.join(' | ')}');
  }

  String _sanitizeDiagnosticValue(String value) {
    var sanitized = value;
    if (_apiKey.isNotEmpty) {
      sanitized = sanitized.replaceAll(_apiKey, '[redacted]');
    }
    sanitized = sanitized
        .replaceAll(RegExp(r'AIza[0-9A-Za-z_-]{20,}'), '[redacted]')
        .replaceAll(
          RegExp(r'bearer\s+\S+', caseSensitive: false),
          'Bearer [redacted]',
        )
        .replaceAll(RegExp(r'https?://\S+'), '[URL redacted]')
        .replaceAll(
          RegExp(
            r'(?:access_token|token|key)\s*[=:]\s*[^&\s,;]+',
            caseSensitive: false,
          ),
          '[credential redacted]',
        )
        .replaceAll(
          RegExp(
            r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
            caseSensitive: false,
          ),
          '[email redacted]',
        );
    return sanitized.length > 500
        ? '${sanitized.substring(0, 500)}…'
        : sanitized;
  }

  String _buildQuery(String term, String filter) {
    switch (filter) {
      case 'title':
        return 'intitle:$term';
      case 'author':
        return 'inauthor:$term';
      default:
        return term;
    }
  }

  BookModel _parseVolume(Map<String, dynamic> item) {
    final volumeId = item['id']?.toString() ?? '';
    final rawInfo = item['volumeInfo'];
    final info = rawInfo is Map
        ? Map<String, dynamic>.from(rawInfo)
        : <String, dynamic>{};

    final title = info['title']?.toString() ?? 'Sem título';

    final rawAuthors = info['authors'];
    final authors = (rawAuthors is List)
        ? rawAuthors.map((a) => a.toString()).toList()
        : <String>[];

    int pageCount = 0;
    final rawPages = info['pageCount'];
    if (rawPages is num && rawPages > 0) pageCount = rawPages.toInt();

    String thumbnail = '';
    final imageLinks = info['imageLinks'];
    if (imageLinks is Map) {
      final raw = imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
      thumbnail = raw.toString().replaceFirst('http://', 'https://');
    }

    return BookModel(
      id: volumeId,
      googleBooksId: volumeId,
      title: title,
      authors: authors,
      pageCount: pageCount,
      thumbnailUrl: thumbnail,
      status: BookStatus.queroLer,
      addedAt: DateTime.now(),
    );
  }
}
