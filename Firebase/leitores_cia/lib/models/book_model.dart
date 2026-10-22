import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeração com os três status exclusivos de um livro na estante (RN-01).
enum BookStatus {
  queroLer('QUERO_LER', 'Quero Ler'),
  lendo('LENDO', 'Lendo'),
  lidos('LIDOS', 'Lidos');

  final String firestoreValue;
  final String label;

  const BookStatus(this.firestoreValue, this.label);

  static BookStatus fromString(String? value) {
    if (value == null) return BookStatus.queroLer;
    switch (value.toUpperCase()) {
      case 'LENDO':
        return BookStatus.lendo;
      case 'LIDOS':
      case 'LIDO':
        return BookStatus.lidos;
      case 'QUERO_LER':
      case 'QUERO LER':
      default:
        return BookStatus.queroLer;
    }
  }
}

/// Modelo de dados que representa um livro na subcoleção users/{userId}/books.
class BookModel {
  final String id;
  final String googleBooksId;
  final String title;
  final List<String> authors;
  final int pageCount;
  final String thumbnailUrl;
  final BookStatus status;
  final DateTime addedAt;
  final DateTime? updatedAt;

  const BookModel({
    required this.id,
    this.googleBooksId = '',
    required this.title,
    this.authors = const [],
    this.pageCount = 0,
    this.thumbnailUrl = '',
    this.status = BookStatus.queroLer,
    required this.addedAt,
    this.updatedAt,
  });

  /// Retorna os autores formatados para exibição textual.
  String get authorsDisplay {
    if (authors.isEmpty) return 'Autor desconhecido';
    return authors.join(', ');
  }

  /// Retorna a contagem de páginas sanitizada (RN-03: valor inteiro >= 0).
  int get safePageCount => pageCount > 0 ? pageCount : 0;

  /// Cria uma instância a partir de um mapa de dados (ex: DocumentSnapshot do Firestore).
  factory BookModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    // Tratamento seguro de páginas conforme RN-03
    int parsedPageCount = 0;
    final rawPages = map['pageCount'];
    if (rawPages is int && rawPages > 0) {
      parsedPageCount = rawPages;
    } else if (rawPages is num && rawPages > 0) {
      parsedPageCount = rawPages.toInt();
    } else if (rawPages is String) {
      parsedPageCount = int.tryParse(rawPages) ?? 0;
      if (parsedPageCount < 0) parsedPageCount = 0;
    }

    // Tratamento seguro de datas do Firestore (Timestamp ou int)
    DateTime parsedAddedAt = DateTime.now();
    final rawAddedAt = map['addedAt'];
    if (rawAddedAt is Timestamp) {
      parsedAddedAt = rawAddedAt.toDate();
    } else if (rawAddedAt is int) {
      parsedAddedAt = DateTime.fromMillisecondsSinceEpoch(rawAddedAt);
    }

    DateTime? parsedUpdatedAt;
    final rawUpdatedAt = map['updatedAt'];
    if (rawUpdatedAt is Timestamp) {
      parsedUpdatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is int) {
      parsedUpdatedAt = DateTime.fromMillisecondsSinceEpoch(rawUpdatedAt);
    }

    // Tratamento de autores
    List<String> parsedAuthors = [];
    final rawAuthors = map['authors'];
    if (rawAuthors is List) {
      parsedAuthors = rawAuthors.map((e) => e.toString()).toList();
    }

    return BookModel(
      id: id.isNotEmpty ? id : (map['id']?.toString() ?? ''),
      googleBooksId: map['googleBooksId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Sem título',
      authors: parsedAuthors,
      pageCount: parsedPageCount,
      thumbnailUrl: map['thumbnailUrl']?.toString() ?? '',
      status: BookStatus.fromString(map['status']?.toString()),
      addedAt: parsedAddedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  /// Cria uma cópia com campos atualizados.
  BookModel copyWith({
    String? id,
    String? googleBooksId,
    String? title,
    List<String>? authors,
    int? pageCount,
    String? thumbnailUrl,
    BookStatus? status,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      googleBooksId: googleBooksId ?? this.googleBooksId,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      pageCount: pageCount ?? this.pageCount,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converte para Map compatível com gravação no Cloud Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'googleBooksId': googleBooksId,
      'title': title,
      'authors': authors,
      'pageCount': safePageCount,
      'thumbnailUrl': thumbnailUrl,
      'status': status.firestoreValue,
      'addedAt': Timestamp.fromDate(addedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
