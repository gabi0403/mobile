import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leitores_cia/core/theme/app_theme.dart';
import 'package:leitores_cia/models/book_model.dart';
import 'package:leitores_cia/screens/stats/stats_screen.dart';
import 'package:leitores_cia/services/book_service.dart';

class FakeStatsBookService implements BookService {
  FakeStatsBookService(this.statsController);

  final StreamController<Map<String, dynamic>?> statsController;
  String? queriedUserId;

  @override
  Stream<Map<String, dynamic>?> streamReadingStats(String userId) {
    queriedUserId = userId;
    return statsController.stream;
  }

  @override
  Stream<List<BookModel>> streamBooks(String userId, {BookStatus? status}) {
    return const Stream.empty();
  }

  @override
  Future<String> addBook(String userId, BookModel book) async => book.id;

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

  testWidgets('exibe carregamento e atualiza os totais reativamente', (
    tester,
  ) async {
    final controller = StreamController<Map<String, dynamic>?>();
    final service = FakeStatsBookService(controller);
    addTearDown(controller.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatsScreen(userId: 'reader-123', bookService: service),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(service.queriedUserId, 'reader-123');

    controller.add({'totalBooksRead': 3, 'totalPagesRead': 742});
    await tester.pumpAndSettle();

    expect(find.text('Jornada Literária'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('742'), findsOneWidget);

    controller.add({'totalBooksRead': 4, 'totalPagesRead': 1000});
    await tester.pumpAndSettle();

    expect(find.text('4'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
    expect(find.text('3'), findsNothing);
  });

  testWidgets('exibe estado inicial acolhedor quando o resumo não foi carregado', (
    tester,
  ) async {
    final controller = StreamController<Map<String, dynamic>?>();
    final service = FakeStatsBookService(controller);
    addTearDown(controller.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatsScreen(userId: 'reader-456', bookService: service),
        ),
      ),
    );

    controller.add(null);
    await tester.pumpAndSettle();

    expect(find.text('Sua jornada está começando'), findsOneWidget);
    expect(
      find.textContaining('Marque seus livros como "Lidos"'),
      findsOneWidget,
    );
  });

  testWidgets(
      'exibe totais zerados e aviso acolhedor quando a lista de lidos está vazia', (
    tester,
  ) async {
    final controller = StreamController<Map<String, dynamic>?>();
    final service = FakeStatsBookService(controller);
    addTearDown(controller.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatsScreen(userId: 'reader-empty', bookService: service),
        ),
      ),
    );

    controller.add({'totalBooksRead': 0, 'totalPagesRead': 0});
    await tester.pumpAndSettle();

    expect(find.text('Jornada Literária'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.textContaining('Sua jornada está começando!'), findsOneWidget);
  });

  testWidgets('apresenta erro de leitura e ação para tentar novamente', (
    tester,
  ) async {
    final controller = StreamController<Map<String, dynamic>?>();
    final service = FakeStatsBookService(controller);
    addTearDown(controller.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatsScreen(userId: 'reader-789', bookService: service),
        ),
      ),
    );

    controller.addError(StateError('Firestore indisponível'));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar suas estatísticas'),
      findsOneWidget,
    );
    expect(
      find.text('Verifique sua conexão e tente novamente.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
