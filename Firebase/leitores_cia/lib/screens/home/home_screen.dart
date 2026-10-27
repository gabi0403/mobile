import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../services/books_api_service.dart';
import '../../widgets/book_card.dart';
import '../search/book_search_screen.dart';
import '../stats/stats_screen.dart';

/// Tela principal da Estante Digital (Etapa 2).
///
/// Implementa:
/// - Visualização em abas: "Lendo", "Quero Ler" e "Lidos" com contadores dinâmicos (RN-01, RF-05, RF-07)
/// - Conexão em tempo real à subcoleção users/{userId}/books via Cloud Firestore
/// - Isolamento multiusuário rigoroso (RN-06, RNF-02)
/// - Renderização otimizada com rolagem suave (RNF-07)
/// - Transição de status (RF-08) e exclusão com diálogo de confirmação (RF-09, RN-04)
/// - Bottom Navigation Bar com os três destinos previstos no DESIGN.md
class HomeScreen extends StatefulWidget {
  final AuthService? authService;
  final BookService? bookService;
  final BooksApiService? booksApiService;

  const HomeScreen({
    super.key,
    this.authService,
    this.bookService,
    this.booksApiService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final BookService _bookService;
  late final BooksApiService _booksApiService;

  BookStatus _selectedTab = BookStatus.lendo;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _bookService = widget.bookService ?? BookService();
    _booksApiService = widget.booksApiService ?? OpenLibraryApiService();
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Perfil & Sessão',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Conectado como: ${user?.email ?? 'Usuário Autenticado'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              if (user?.displayName != null && user!.displayName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Nome: ${user.displayName}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Encerrar Sessão (Logout)'),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _authService.signOut();
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Diálogo modal de confirmação para remoção de livro (DESIGN.md seções 4.2 e 5.7).
  void _confirmDeleteBook(BuildContext context, String userId, BookModel book) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remover da Estante?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Tem certeza que deseja remover "${book.title}" da sua estante? Esta ação não pode ser desfeita.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(ctx).pop();
                    try {
                      await _bookService.deleteBook(userId, book.id);
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Livro removido com sucesso.'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Falha ao remover o livro: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirmar Exclusão'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleStatusChange(
    BuildContext context,
    String userId,
    BookModel book,
    BookStatus newStatus,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _bookService.updateBookStatus(userId, book.id, newStatus);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Status alterado para "${newStatus.label}".'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Falha ao atualizar status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_stories, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Leitores & Cia.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Literata',
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Perfil e Logout',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.secondaryContainer,
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userId.isEmpty
          ? const Center(
              child: Text('Nenhum usuário autenticado encontrado.'),
            )
          : _currentBottomNavIndex == 1
              ? BookSearchScreen(
                  userId: userId,
                  booksApiService: _booksApiService,
                  bookService: _bookService,
                )
              : _currentBottomNavIndex == 2
                  ? StatsScreen(
                      userId: userId,
                      bookService: _bookService,
                    )
                  : StreamBuilder<List<BookModel>>(
              stream: _bookService.streamBooks(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Erro ao carregar sua estante',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allBooks = snapshot.data ?? [];

                // Contadores por categoria
                final lendoCount = allBooks
                    .where((b) => b.status == BookStatus.lendo)
                    .length;
                final queroLerCount = allBooks
                    .where((b) => b.status == BookStatus.queroLer)
                    .length;
                final lidosCount = allBooks
                    .where((b) => b.status == BookStatus.lidos)
                    .length;

                // Livros filtrados para a aba ativa
                final currentTabBooks = allBooks
                    .where((b) => b.status == _selectedTab)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho acolhedor e resumo do acervo
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Olá, Leitor(a)! ☕',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Literata',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  '${allBooks.length} obras',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sua biblioteca pessoal na nuvem',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Abas de seleção de estante (Tabs com badges numéricos)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildTabPill(
                            status: BookStatus.lendo,
                            count: lendoCount,
                            theme: theme,
                          ),
                          const SizedBox(width: 8),
                          _buildTabPill(
                            status: BookStatus.queroLer,
                            count: queroLerCount,
                            theme: theme,
                          ),
                          const SizedBox(width: 8),
                          _buildTabPill(
                            status: BookStatus.lidos,
                            count: lidosCount,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista de livros da estante ativa (RNF-07: ListView.builder)
                    Expanded(
                      child: currentTabBooks.isEmpty
                          ? _buildEmptyState(theme)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              itemCount: currentTabBooks.length,
                              itemBuilder: (context, index) {
                                final book = currentTabBooks[index];
                                return BookCard(
                                  book: book,
                                  onStatusChanged: (newStatus) =>
                                      _handleStatusChange(
                                    context,
                                    userId,
                                    book,
                                    newStatus,
                                  ),
                                  onDelete: () => _confirmDeleteBook(
                                    context,
                                    userId,
                                    book,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.surfaceContainerHigh.withAlpha(120),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentBottomNavIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: const Color(0xFFC2EDCB),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories, color: AppColors.primary),
              label: 'Estante',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search, color: AppColors.primary),
              label: 'Buscar',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
              label: 'Estatísticas',
            ),
          ],
          onDestinationSelected: (index) {
            setState(() => _currentBottomNavIndex = index);
          },
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required BookStatus status,
    required int count,
    required ThemeData theme,
  }) {
    final isSelected = _selectedTab == status;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = status;
        });
      },
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerHigh,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(60)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum livro em "${_selectedTab.label}"',
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Literata',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Os livros cadastrados com esta estante aparecerão aqui.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
