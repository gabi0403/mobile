abstract class ApiConfig {
  // Captura a chave passada via --dart-define no terminal ou na IDE
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY');

  // URLs Base oficiais do TMDB
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
}