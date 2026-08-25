import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/movie.dart';

class TmdbService {
  // Realiza a busca de filmes no endpoint /search/movie
  static Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('${ApiConfig.baseUrl}/search/movie').replace(
      queryParameters: {
        'api_key': ApiConfig.apiKey,
        'query': query,
        'language': 'pt-BR',
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List results = data['results'] ?? [];

        return results.map((item) {
          item['media_type'] = 'movie'; // Identifica como filme
          return Movie.fromTmdbJson(item);
        }).toList();
      } else {
        throw Exception('Erro no servidor TMDB: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar com a API de filmes: $e');
    }
  }

  // Realiza a busca de séries no endpoint /search/tv
  static Future<List<Movie>> searchTvShows(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('${ApiConfig.baseUrl}/search/tv').replace(
      queryParameters: {
        'api_key': ApiConfig.apiKey,
        'query': query,
        'language': 'pt-BR',
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List results = data['results'] ?? [];

        return results.map((item) {
          item['media_type'] = 'tv'; // Identifica como série
          return Movie.fromTmdbJson(item);
        }).toList();
      } else {
        throw Exception('Erro no servidor TMDB: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha ao conectar com a API de séries: $e');
    }
  }

  // Realiza a busca combinada (Filmes + Séries)
  static Future<List<Movie>> searchAll(String query) async {
    if (query.trim().isEmpty) return [];

    final results = await Future.wait([
      searchMovies(query),
      searchTvShows(query),
    ]);

    return [...results[0], ...results[1]];
  }
}