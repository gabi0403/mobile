import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

/// Serviço responsável pelas operações na subcoleção de livros do usuário no Cloud Firestore:
/// users/{userId}/books/{bookId}
///
/// Atende às regras:
/// - RN-01: Exclusividade de status ("QUERO_LER", "LENDO", "LIDOS")
/// - RN-06: Isolamento multiusuário (cada usuário acessa apenas seus próprios registros)
/// - RNF-02: Autenticação obrigatória para acesso
class BookService {
  final FirebaseFirestore _firestore;

  BookService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Retorna a referência da subcoleção de livros do usuário.
  CollectionReference<Map<String, dynamic>> _booksRef(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('O identificador do usuário (userId) não pode ser vazio.');
    }
    return _firestore.collection('users').doc(userId).collection('books');
  }

  /// Escuta em tempo real os livros da estante do usuário (com filtro opcional por status).
  Stream<List<BookModel>> streamBooks(String userId, {BookStatus? status}) {
    Query<Map<String, dynamic>> query = _booksRef(userId);

    if (status != null) {
      query = query.where('status', isEqualTo: status.firestoreValue);
    }

    // Ordena pelos livros adicionados mais recentemente
    query = query.orderBy('addedAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  /// Escuta o resumo de estatísticas calculado em tempo real a partir dos livros do usuário no Firestore.
  ///
  /// Dispensa Cloud Functions e plano Blaze, agregando diretamente os livros com status "LIDOS"
  /// da subcoleção users/{userId}/books:
  /// - RN-02: Apenas livros com status "Lidos" são computados.
  /// - RN-03: Livros sem páginas válidas computam 1 livro e 0 páginas adicionais.
  /// - RN-04: Mudanças de status ou remoções são refletidas imediatamente.
  /// - RN-06: Isolamento multiusuário estrito por userId.
  Stream<Map<String, dynamic>?> streamReadingStats(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('O identificador do usuário (userId) não pode ser vazio.');
    }

    return _booksRef(userId)
        .where('status', isEqualTo: BookStatus.lidos.firestoreValue)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs.map((doc) {
        return BookModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      final totalBooksRead = books.length;
      final totalPagesRead = books.fold<int>(
        0,
        (total, book) => total + book.safePageCount,
      );

      return {
        'totalBooksRead': totalBooksRead,
        'totalPagesRead': totalPagesRead,
      };
    });
  }

  /// Adiciona uma nova obra à estante do usuário.
  Future<String> addBook(String userId, BookModel book) async {
    final collection = _booksRef(userId);

    if (book.googleBooksId.isNotEmpty) {
      final existingBooks = await collection
          .where('googleBooksId', isEqualTo: book.googleBooksId)
          .limit(1)
          .get();
      if (existingBooks.docs.isNotEmpty) {
        return existingBooks.docs.first.id;
      }

      final stableId = base64Url
          .encode(utf8.encode(book.googleBooksId))
          .replaceAll('=', '');
      final docRef = collection.doc(stableId);
      final data = book.copyWith(id: docRef.id).toMap();

      return _firestore.runTransaction((transaction) async {
        final existingBook = await transaction.get(docRef);
        if (existingBook.exists) return docRef.id;

        transaction.set(docRef, data);
        return docRef.id;
      });
    }

    final docRef = book.id.isNotEmpty ? collection.doc(book.id) : collection.doc();

    final data = book.copyWith(id: docRef.id).toMap();
    await docRef.set(data);
    return docRef.id;
  }

  /// Altera o status de um livro entre as estantes (RN-01, RF-08).
  Future<void> updateBookStatus(
    String userId,
    String bookId,
    BookStatus newStatus,
  ) async {
    if (bookId.isEmpty) {
      throw ArgumentError('O identificador do livro (bookId) não pode ser vazio.');
    }

    await _booksRef(userId).doc(bookId).update({
      'status': newStatus.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove uma obra da estante do usuário (RF-09, RN-04).
  Future<void> deleteBook(String userId, String bookId) async {
    if (bookId.isEmpty) {
      throw ArgumentError('O identificador do livro (bookId) não pode ser vazio.');
    }

    await _booksRef(userId).doc(bookId).delete();
  }
}
