class Movie {
  final int id;
  final String title;
  final String posterPath;
  final double tmdbRating;  // Nota média fornecida pelo TMDB
  final double userRating;  // Nota atribuída pelo usuário localmente
  final String? userId;     // ID do usuário dono do favorito
  final String mediaType;   // Tipo de mídia: 'movie' ou 'tv'

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.tmdbRating,
    required this.mediaType,
    this.userRating = 0.0,
    this.userId,
  });

  // Converte o JSON recebido da API TMDB em um objeto Movie
  factory Movie.fromTmdbJson(Map<String, dynamic> json) {
    // Se a API não retornar media_type explícito, identificamos pela presença do 'title' (Filme) ou 'name' (Série)
    final inferredMediaType = json['media_type'] ?? (json['title'] != null ? 'movie' : 'tv');

    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? 'Sem título',
      posterPath: json['poster_path'] ?? '',
      tmdbRating: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      mediaType: inferredMediaType,
    );
  }

  // Converte o objeto Movie para Map (gravação no banco SQLite local)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'tmdbRating': tmdbRating,
      'userRating': userRating,
      'userId': userId,
      'mediaType': mediaType,
    };
  }

  // Cria o objeto Movie a partir de um registro retornado do SQLite
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      posterPath: map['posterPath'],
      tmdbRating: (map['tmdbRating'] as num).toDouble(),
      userRating: (map['userRating'] as num).toDouble(),
      userId: map['userId'],
      mediaType: map['mediaType'] ?? 'movie',
    );
  }

  // Retorna a URL completa para exibição da imagem
  String get fullPosterUrl {
    if (posterPath.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}