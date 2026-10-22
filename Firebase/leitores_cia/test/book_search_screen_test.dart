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

  @override
  Future<List<BookModel>> search(String query, {String filter = 'all'}) async {
    lastQuery = query;
    lastFilter = filter;
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
}
