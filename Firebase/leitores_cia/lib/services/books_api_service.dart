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

/// Implementação que consulta a Open Library Search API.
///
/// Não requer chave de API (pesquisa pública).
class OpenLibraryApiService implements BooksApiService {
  final http.Client _client;

  OpenLibraryApiService({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<BookModel>> search(String query, {String filter = 'all'}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final parameters = <String, String>{
      'limit': '20',
      'fields':
          'key,title,author_name,first_publish_year,cover_i,cover_edition_key,number_of_pages_median',
    };

    switch (filter) {
      case 'title':
        parameters['title'] = trimmed;
        break;
      case 'author':
        parameters['author'] = trimmed;
        break;
      default:
        parameters['q'] = trimmed;
        break;
    }

    final uri = Uri.https(
      'openlibrary.org',
      '/search.json',
      parameters,
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 429) {
        if (kDebugMode) {
          debugPrint('Open Library API diagnostic: HTTP 429 (Rate limit)');
        }
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

      final docs = decoded['docs'];
      if (docs == null || docs is! List) return [];

      return docs
          .whereType<Map>()
          .map((item) => _parseDoc(Map<String, dynamic>.from(item)))
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

  BookModel _parseDoc(Map<String, dynamic> item) {
    // Identificador
    final rawKey = (item['key'] ?? item['id'] ?? item['work_key'])
            ?.toString()
            .trim() ??
        '';
    final id = rawKey
        .replaceFirst(RegExp(r'^/+(works|books)/+'), '')
        .replaceAll('/', '_')
        .trim();

    // Título
    final rawTitle = item['title']?.toString().trim();
    final title =
        (rawTitle != null && rawTitle.isNotEmpty) ? rawTitle : 'Sem título';

    // Autores
    List<String> authors = [];
    final rawAuthors = item['author_name'] ?? item['authors'];
    if (rawAuthors is List) {
      authors = rawAuthors
          .map((a) => a.toString().trim())
          .where((a) => a.isNotEmpty)
          .toList();
    } else if (rawAuthors is String && rawAuthors.trim().isNotEmpty) {
      authors = [rawAuthors.trim()];
    }

    // Ano de publicação
    int? publishYear;
    final rawYear = item['first_publish_year'];
    if (rawYear is int) {
      publishYear = rawYear;
    } else if (rawYear is num) {
      publishYear = rawYear.toInt();
    } else if (rawYear is String) {
      publishYear = int.tryParse(rawYear);
    } else if (item['publish_year'] is List &&
        (item['publish_year'] as List).isNotEmpty) {
      final firstYear = (item['publish_year'] as List).first;
      if (firstYear is num) {
        publishYear = firstYear.toInt();
      } else if (firstYear is String) {
        publishYear = int.tryParse(firstYear);
      }
    }

    // Número de páginas (Open Library fornece number_of_pages_median)
    int pageCount = 0;
    final rawPages = item['number_of_pages_median'] ??
        item['number_of_pages'] ??
        item['pageCount'];
    if (rawPages is num && rawPages > 0) {
      pageCount = rawPages.toInt();
    } else if (rawPages is String) {
      final parsed = int.tryParse(rawPages) ?? 0;
      if (parsed > 0) pageCount = parsed;
    }

    // Capa do livro
    String thumbnailUrl = '';
    final coverI = item['cover_i'];
    if (coverI != null && (coverI is int || (coverI is num && coverI > 0))) {
      thumbnailUrl = 'https://covers.openlibrary.org/b/id/$coverI-M.jpg';
    } else if (item['cover_edition_key'] != null &&
        item['cover_edition_key'].toString().trim().isNotEmpty) {
      final olid = item['cover_edition_key'].toString().trim();
      thumbnailUrl = 'https://covers.openlibrary.org/b/olid/$olid-M.jpg';
    } else if (item['thumbnailUrl'] != null &&
        item['thumbnailUrl'].toString().trim().isNotEmpty) {
      thumbnailUrl = item['thumbnailUrl']
          .toString()
          .trim()
          .replaceFirst('http://', 'https://');
    } else if (item['thumbnail'] != null &&
        item['thumbnail'].toString().trim().isNotEmpty) {
      thumbnailUrl = item['thumbnail']
          .toString()
          .trim()
          .replaceFirst('http://', 'https://');
    }

    return BookModel(
      id: id,
      googleBooksId: id,
      title: title,
      authors: authors,
      pageCount: pageCount,
      thumbnailUrl: thumbnailUrl,
      publishYear: publishYear,
      status: BookStatus.queroLer,
      addedAt: DateTime.now(),
    );
  }
}

/// Classe mantida para compatibilidade retroativa.
@Deprecated('Use OpenLibraryApiService')
class GoogleBooksApiService extends OpenLibraryApiService {
  GoogleBooksApiService({
    super.client,
    @Deprecated('Chave não necessária na Open Library') String? apiKey,
  });
}
