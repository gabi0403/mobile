import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leitores_cia/core/theme/app_theme.dart';
import 'package:leitores_cia/models/book_model.dart';
import 'package:leitores_cia/screens/search/book_search_screen.dart';
import 'package:leitores_cia/services/book_service.dart';
import 'package:leitores_cia/services/books_api_service.dart';

class FakeBooksApiService implements BooksApiService {
  FakeBooksApiService(this.books);

  final List<BookModel> books;
  String? lastQuery;
  String? lastFilter;
  int callCount = 0;
  Future<List<BookModel>> Function(String query, {required String filter})?
  searchHandler;

  @override
  Future<List<BookModel>> search(String query, {String filter = 'all'}) async {
    callCount++;
    lastQuery = query;
    lastFilter = filter;
    final handler = searchHandler;
    if (handler != null) return handler(query, filter: filter);
    return books;
  }
}

class FakeBookService implements BookService {
  final List<BookModel> books = [];

  @override
  Stream<List<BookModel>> streamBooks(String userId, {BookStatus? status}) {
    return Stream.value(books);
  }

  @override
  Stream<Map<String, dynamic>?> streamReadingStats(String userId) {
    return Stream.value(null);
  }

  @override
  Future<String> addBook(String userId, BookModel book) async {
    books.add(book);
    return book.id;
  }

  @override
  Future<void> updateBookStatus(
    String userId,
    String bookId,
    BookStatus newStatus,
  ) async {}

  @override
  Future<void> deleteBook(String userId, String bookId) async {}
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('busca e permite escolher uma estante ao adicionar o livro', (
    tester,
  ) async {
    final book = BookModel(
      id: 'google-book-1',
      googleBooksId: 'google-book-1',
      title: 'Duna',
      authors: const ['Frank Herbert'],
      pageCount: 412,
      addedAt: DateTime(2024),
    );
    final apiService = FakeBooksApiService([book]);
    final bookService = FakeBookService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BookSearchScreen(
            userId: 'reader-1',
            booksApiService: apiService,
            bookService: bookService,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Duna');
    await tester.tap(find.byTooltip('Buscar livros'));
    await tester.pumpAndSettle();

    expect(apiService.lastQuery, 'Duna');
    expect(apiService.lastFilter, 'all');
    expect(find.text('Duna'), findsNWidgets(2));
    expect(find.text('412 páginas'), findsOneWidget);

    await tester.tap(find.byTooltip('Escolher estante'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lendo').last);
    await tester.pumpAndSettle();

    expect(bookService.books, hasLength(1));
    expect(bookService.books.single.status, BookStatus.lendo);
  });

  testWidgets('permite tentar novamente após uma falha de busca', (
    tester,
  ) async {
    final book = BookModel(
      id: 'google-book-1',
      googleBooksId: 'google-book-1',
      title: 'Duna',
      authors: const ['Frank Herbert'],
      pageCount: 412,
      addedAt: DateTime(2024),
    );
    final apiService = FakeBooksApiService([book]);
    apiService.searchHandler = (query, {required filter}) async {
      if (apiService.callCount == 1) {
        throw Exception('Falha temporária');
      }
      return [book];
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BookSearchScreen(
            userId: 'reader-1',
            booksApiService: apiService,
            bookService: FakeBookService(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Duna');
    await tester.tap(find.byTooltip('Buscar livros'));
    await tester.pumpAndSettle();

    expect(find.text('Falha temporária'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(apiService.callCount, 2);
    expect(find.text('412 páginas'), findsOneWidget);
  });

  testWidgets('ignora uma segunda busca enquanto a primeira está ativa', (
    tester,
  ) async {
    final book = BookModel(
      id: 'google-book-1',
      googleBooksId: 'google-book-1',
      title: 'Duna',
      authors: const ['Frank Herbert'],
      pageCount: 412,
      addedAt: DateTime(2024),
    );
    final apiService = FakeBooksApiService([book]);
    final response = Completer<List<BookModel>>();
    apiService.searchHandler = (_, {required filter}) => response.future;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BookSearchScreen(
            userId: 'reader-1',
            booksApiService: apiService,
            bookService: FakeBookService(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Duna');
    await tester.tap(find.byTooltip('Buscar livros'));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    expect(apiService.callCount, 1);

    response.complete([book]);
    await tester.pumpAndSettle();
    expect(find.text('412 páginas'), findsOneWidget);
  });
}
