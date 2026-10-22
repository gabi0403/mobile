import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leitores_cia/core/theme/app_colors.dart';
import 'package:leitores_cia/core/theme/app_theme.dart';
import 'package:leitores_cia/models/book_model.dart';
import 'package:leitores_cia/screens/auth/auth_gate.dart';
import 'package:leitores_cia/screens/auth/login_screen.dart';
import 'package:leitores_cia/screens/auth/register_screen.dart';
import 'package:leitores_cia/screens/home/home_screen.dart';
import 'package:leitores_cia/services/auth_service.dart';
import 'package:leitores_cia/services/book_service.dart';

/// Fake de AuthService para testes de widget offline e determinísticos.
class FakeAuthService implements AuthService {
  final StreamController<User?> _controller =
      StreamController<User?>.broadcast();
  User? _user;
  bool signOutCalled = false;

  FakeAuthService({User? initialUser}) : _user = initialUser;

  @override
  Stream<User?> get authStateChanges async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (password == 'wrongpass') {
      throw 'E-mail ou senha incorretos. Verifique suas credenciais.';
    }
    _user = FakeUser(uid: 'test_user_id', email: email);
    _controller.add(_user);
    return FakeUserCredential();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (password.length < 6) {
      throw 'A senha é muito fraca. Ela deve conter no mínimo 6 caracteres.';
    }
    _user = FakeUser(uid: 'new_user_id', email: email, displayName: displayName);
    _controller.add(_user);
    return FakeUserCredential();
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _user = null;
    _controller.add(null);
  }
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({required this.uid, this.email, this.displayName});
}

class FakeUserCredential extends Fake implements UserCredential {}

/// Fake de BookService para testes offline da subcoleção users/{userId}/books.
class FakeBookService implements BookService {
  final List<BookModel> _books = [];
  final StreamController<List<BookModel>> _controller =
      StreamController<List<BookModel>>.broadcast();

  String? lastQueriedUserId;
  bool updateStatusCalled = false;
  bool deleteCalled = false;
  String? lastDeletedBookId;
  BookStatus? lastUpdatedStatus;

  FakeBookService({List<BookModel>? initialBooks}) {
    if (initialBooks != null) {
      _books.addAll(initialBooks);
    }
  }

  @override
  Stream<List<BookModel>> streamBooks(String userId, {BookStatus? status}) async* {
    lastQueriedUserId = userId;
    List<BookModel> filtered = List.from(_books);
    if (status != null) {
      filtered = filtered.where((b) => b.status == status).toList();
    }
    yield filtered;
    yield* _controller.stream.map((list) {
      if (status != null) {
        return list.where((b) => b.status == status).toList();
      }
      return list;
    });
  }

  @override
  Future<String> addBook(String userId, BookModel book) async {
    final newBook = book.id.isEmpty
        ? book.copyWith(id: 'book_${_books.length + 1}')
        : book;
    _books.add(newBook);
    _controller.add(List.from(_books));
    return newBook.id;
  }

  @override
  Future<void> updateBookStatus(
    String userId,
    String bookId,
    BookStatus newStatus,
  ) async {
    updateStatusCalled = true;
    lastUpdatedStatus = newStatus;
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(status: newStatus);
      _controller.add(List.from(_books));
    }
  }

  @override
  Future<void> deleteBook(String userId, String bookId) async {
    deleteCalled = true;
    lastDeletedBookId = bookId;
    _books.removeWhere((b) => b.id == bookId);
    _controller.add(List.from(_books));
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Etapa 0 - Tema e Configuração Visual', () {
    test('AppColors tokens correspondem à especificação do DESIGN.md', () {
      expect(AppColors.primary, const Color(0xFF3E644A));
      expect(AppColors.surface, const Color(0xFFFCF9F4));
      expect(AppColors.onSurface, const Color(0xFF1C1C19));
      expect(AppColors.secondary, const Color(0xFF6C5B51));
      expect(AppColors.tertiary, const Color(0xFF8D4932));
      expect(AppColors.error, const Color(0xFFBA1A1A));
    });

    test('AppTheme lightTheme aplica propriedades do Material 3', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.surface);
    });
  });

  group('Etapa 1 - Telas de Autenticação, Cadastro e Sessão (RF-01, RF-02, CA-01)', () {
    testWidgets('LoginScreen renderiza campos de e-mail, senha e botão principal', (tester) async {
      final fakeAuth = FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LoginScreen(authService: fakeAuth),
        ),
      );

      expect(find.text('Leitores & Cia.'), findsOneWidget);
      expect(find.text('Seu cantinho de leitura aconchegante'), findsOneWidget);
      expect(find.text('Bem-vindo(a) de volta'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar na Estante'), findsOneWidget);
      expect(find.text('Cadastre-se'), findsOneWidget);
    });

    testWidgets('LoginScreen valida campos obrigatórios ao submeter formulário vazio', (tester) async {
      final fakeAuth = FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LoginScreen(authService: fakeAuth),
        ),
      );

      // Clica em Entrar sem preencher
      await tester.tap(find.text('Entrar na Estante'));
      await tester.pump();

      expect(find.text('Por favor, informe seu e-mail.'), findsOneWidget);
      expect(find.text('Por favor, informe sua senha.'), findsOneWidget);
    });

    testWidgets('LoginScreen permite alternar visibilidade da senha', (tester) async {
      final fakeAuth = FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: LoginScreen(authService: fakeAuth),
        ),
      );

      final visibilityBtn = find.byIcon(Icons.visibility_outlined);
      expect(visibilityBtn, findsOneWidget);

      await tester.tap(visibilityBtn);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('RegisterScreen renderiza campos e validação de senha mínima de 6 caracteres', (tester) async {
      final fakeAuth = FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: RegisterScreen(authService: fakeAuth),
        ),
      );

      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('Novo leitor'), findsOneWidget);
      expect(find.text('BOOK NOOK'), findsOneWidget);
      expect(find.text('Criar minha conta'), findsOneWidget);

      // Preenche senha com menos de 6 caracteres
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'usuario@exemplo.com'); // email
      await tester.enterText(textFields.at(2), '12345'); // senha < 6
      await tester.enterText(textFields.at(3), '12345'); // confirm

      final submitBtn = find.text('Criar minha conta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('A senha deve ter no mínimo 6 caracteres.'), findsOneWidget);
    });

    testWidgets('RegisterScreen valida divergência entre senha e confirmação', (tester) async {
      final fakeAuth = FakeAuthService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: RegisterScreen(authService: fakeAuth),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(2), 'senha123');
      await tester.enterText(textFields.at(3), 'outrasenha');

      final submitBtn = find.text('Criar minha conta');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump();

      expect(find.text('As senhas digitadas não coincidem.'), findsOneWidget);
    });

    testWidgets('HomeScreen apresenta ação de Logout e encerra sessão com segurança', (tester) async {
      final fakeAuth = FakeAuthService(
        initialUser: FakeUser(uid: 'user_123', email: 'leitor@booknook.com'),
      );
      final fakeBooks = FakeBookService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(authService: fakeAuth, bookService: fakeBooks),
        ),
      );

      expect(find.text('Leitores & Cia.'), findsOneWidget);

      // Abre bottom sheet de logout pelo avatar no AppBar
      final profileBtn = find.byTooltip('Perfil e Logout');
      expect(profileBtn, findsOneWidget);
      await tester.tap(profileBtn);
      await tester.pumpAndSettle();

      expect(find.text('Perfil & Sessão'), findsOneWidget);
      expect(find.text('Encerrar Sessão (Logout)'), findsOneWidget);

      // Confirma logout
      await tester.tap(find.text('Encerrar Sessão (Logout)'));
      await tester.pumpAndSettle();

      expect(fakeAuth.signOutCalled, isTrue);
    });

    testWidgets('AuthGate transiciona reativamente entre LoginScreen e HomeScreen', (tester) async {
      final fakeAuth = FakeAuthService();
      final fakeBooks = FakeBookService();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AuthGate(authService: fakeAuth, bookService: fakeBooks),
        ),
      );

      // 1. Inicialmente sem usuário autenticado -> exibe LoginScreen
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // 2. Realiza login -> AuthGate transiciona para HomeScreen
      await fakeAuth.signInWithEmailAndPassword(
        email: 'leitor@booknook.com',
        password: 'password123',
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // 3. Realiza logout -> AuthGate retorna para LoginScreen
      await fakeAuth.signOut();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });
  });

  group('Etapa 2 - Modelagem de Dados, Cloud Firestore e Estante Digital (RF-05, RF-07, RF-08, RF-09, RN-01, RN-03, RN-06)', () {
    test('BookModel serializa e desserializa corretamente tratando RN-03 (páginas ausentes/inválidas)', () {
      final now = DateTime(2026, 10, 22);

      // Caso com páginas válidas
      final book1 = BookModel(
        id: 'book_1',
        title: 'Dom Casmurro',
        authors: ['Machado de Assis'],
        pageCount: 256,
        status: BookStatus.lidos,
        addedAt: now,
      );
      final map1 = book1.toMap();
      expect(map1['title'], 'Dom Casmurro');
      expect(map1['pageCount'], 256);
      expect(map1['status'], 'LIDOS');

      // Caso com páginas nulas ou negativas (RN-03 deve tratar para 0)
      final book2 = BookModel.fromMap({
        'title': 'Obra Desconhecida',
        'authors': ['Autor Desconhecido'],
        'pageCount': -15, // inválido
        'status': 'LIDOS',
        'addedAt': Timestamp.fromDate(now),
      }, id: 'book_2');

      expect(book2.safePageCount, 0);
      expect(book2.status, BookStatus.lidos);
      expect(book2.authorsDisplay, 'Autor Desconhecido');
    });

    test('BookStatus faz parsing seguro com fallback para QUERO_LER (RN-01)', () {
      expect(BookStatus.fromString('LENDO'), BookStatus.lendo);
      expect(BookStatus.fromString('QUERO_LER'), BookStatus.queroLer);
      expect(BookStatus.fromString('LIDOS'), BookStatus.lidos);
      expect(BookStatus.fromString('LIDO'), BookStatus.lidos);
      expect(BookStatus.fromString('DESCONHECIDO'), BookStatus.queroLer);
      expect(BookStatus.fromString(null), BookStatus.queroLer);
    });

    testWidgets('Estante isola por usuário e renderiza abas e contadores dinâmicos', (tester) async {
      final fakeAuth = FakeAuthService(
        initialUser: FakeUser(uid: 'user_456', email: 'estudante@booknook.com'),
      );

      final initialBooks = [
        BookModel(
          id: 'b1',
          title: 'O Hobbit',
          authors: ['J.R.R. Tolkien'],
          pageCount: 310,
          status: BookStatus.lendo,
          addedAt: DateTime.now(),
        ),
        BookModel(
          id: 'b2',
          title: '1984',
          authors: ['George Orwell'],
          pageCount: 326,
          status: BookStatus.queroLer,
          addedAt: DateTime.now(),
        ),
        BookModel(
          id: 'b3',
          title: 'A Revolução dos Bichos',
          authors: ['George Orwell'],
          pageCount: 152,
          status: BookStatus.lidos,
          addedAt: DateTime.now(),
        ),
      ];

      final fakeBookService = FakeBookService(initialBooks: initialBooks);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(
            authService: fakeAuth,
            bookService: fakeBookService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Confirma que o serviço foi consultado com o ID correto do usuário (RN-06)
      expect(fakeBookService.lastQueriedUserId, 'user_456');

      // Verifica cabeçalho e contagem global
      expect(find.text('3 obras'), findsOneWidget);

      // Verifica abas com contagens individuais (rótulos podem aparecer também nos badges dos cards)
      expect(find.text('Lendo'), findsAtLeastNWidgets(1));
      expect(find.text('Quero Ler'), findsAtLeastNWidgets(1));
      expect(find.text('Lidos'), findsAtLeastNWidgets(1));

      // Por padrão a aba inicial é "Lendo"
      expect(find.text('O Hobbit'), findsOneWidget);
      expect(find.text('J.R.R. Tolkien'), findsOneWidget);
      expect(find.text('1984'), findsNothing); // Pertence à aba "Quero Ler"

      // Troca para a aba "Quero Ler"
      await tester.tap(find.text('Quero Ler'));
      await tester.pumpAndSettle();

      expect(find.text('1984'), findsOneWidget);
      expect(find.text('O Hobbit'), findsNothing);

      // Troca para a aba "Lidos"
      await tester.tap(find.text('Lidos'));
      await tester.pumpAndSettle();

      expect(find.text('A Revolução dos Bichos'), findsOneWidget);
      expect(find.text('1984'), findsNothing);
    });

    testWidgets('Estante exibe estado vazio quando não há livros na categoria', (tester) async {
      final fakeAuth = FakeAuthService(
        initialUser: FakeUser(uid: 'user_789', email: 'novo@booknook.com'),
      );
      final fakeBookService = FakeBookService(initialBooks: []);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(
            authService: fakeAuth,
            bookService: fakeBookService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 obras'), findsOneWidget);
      expect(find.text('Nenhum livro em "Lendo"'), findsOneWidget);
      expect(find.text('Os livros cadastrados com esta estante aparecerão aqui.'), findsOneWidget);
    });

    testWidgets('BookCard permite transição de status e exclusão com diálogo de confirmação', (tester) async {
      final fakeAuth = FakeAuthService(
        initialUser: FakeUser(uid: 'user_101', email: 'leitor@booknook.com'),
      );

      final book = BookModel(
        id: 'book_teste',
        title: 'Orgulho e Preconceito',
        authors: ['Jane Austen'],
        pageCount: 424,
        status: BookStatus.lendo,
        addedAt: DateTime.now(),
      );

      final fakeBookService = FakeBookService(initialBooks: [book]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: HomeScreen(
            authService: fakeAuth,
            bookService: fakeBookService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Orgulho e Preconceito'), findsOneWidget);

      // Abre menu de opções do card
      final menuButton = find.byType(PopupMenuButton<String>);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Transiciona status para "Lidos"
      expect(find.text('Mover para "Lidos"'), findsOneWidget);
      await tester.tap(find.text('Mover para "Lidos"'));
      await tester.pumpAndSettle();

      expect(fakeBookService.updateStatusCalled, isTrue);
      expect(fakeBookService.lastUpdatedStatus, BookStatus.lidos);

      // Agora vai para a aba "Lidos" e testa o fluxo de remoção
      await tester.tap(find.text('Lidos'));
      await tester.pumpAndSettle();

      expect(find.text('Orgulho e Preconceito'), findsOneWidget);

      // Abre menu de opções do card novamente
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Clica em "Remover da Estante"
      expect(find.text('Remover da Estante'), findsOneWidget);
      await tester.tap(find.text('Remover da Estante'));
      await tester.pumpAndSettle();

      // Valida apresentação do Modal Bottom Sheet de confirmação de exclusão
      expect(find.text('Remover da Estante?'), findsOneWidget);
      expect(find.text('Confirmar Exclusão'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // Confirma exclusão
      await tester.tap(find.text('Confirmar Exclusão'));
      await tester.pumpAndSettle();

      expect(fakeBookService.deleteCalled, isTrue);
      expect(fakeBookService.lastDeletedBookId, 'book_teste');
      expect(find.text('Orgulho e Preconceito'), findsNothing);
    });
  });
}

