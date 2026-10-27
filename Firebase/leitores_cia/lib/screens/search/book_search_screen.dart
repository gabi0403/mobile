import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../services/books_api_service.dart';

class BookSearchScreen extends StatefulWidget {
  final String userId;
  final BooksApiService booksApiService;
  final BookService bookService;

  const BookSearchScreen({
    super.key,
    required this.userId,
    required this.booksApiService,
    required this.bookService,
  });

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  late final Stream<List<BookModel>> _booksStream;

  String _filter = 'all';
  String? _errorMessage;
  List<BookModel>? _results;
  bool _isLoading = false;
  final Set<String> _addingBookIds = {};

  @override
  void initState() {
    super.initState();
    _booksStream = widget.bookService.streamBooks(widget.userId);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_isLoading) return;

    final query = _queryController.text.trim();
    if (query.length < 2) {
      setState(() {
        _results = null;
        _errorMessage = 'Digite pelo menos 2 caracteres para buscar.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _results = null;
      _errorMessage = null;
    });

    try {
      final results = await widget.booksApiService.search(
        query,
        filter: _filter,
      );
      if (!mounted) return;
      setState(() => _results = results);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addBook(BookModel book, BookStatus status) async {
    if (book.googleBooksId.isEmpty ||
        _addingBookIds.contains(book.googleBooksId)) {
      return;
    }

    setState(() => _addingBookIds.add(book.googleBooksId));
    try {
      await widget.bookService.addBook(
        widget.userId,
        book.copyWith(status: status),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${book.title}" adicionado à estante ${status.label}.'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao adicionar o livro: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _addingBookIds.remove(book.googleBooksId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Encontre sua próxima leitura',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Literata',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pesquise por título ou autor no catálogo Google Books.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _queryController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                onChanged: (_) {
                  if (_results != null || _errorMessage != null) {
                    setState(() {
                      _results = null;
                      _errorMessage = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Título ou autor',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Buscar livros',
                    onPressed: _isLoading ? null : _search,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('Todos', 'all'),
                  _buildFilterChip('Por Título', 'title'),
                  _buildFilterChip('Por Autor', 'author'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildResults(theme),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
          _results = null;
          _errorMessage = null;
        });
      },
      selectedColor: AppColors.primaryFixed,
      labelStyle: TextStyle(
        color: _filter == value ? AppColors.primary : AppColors.secondary,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildMessage(
        icon: Icons.cloud_off,
        title: 'Não foi possível concluir a busca',
        message: _errorMessage!,
        color: AppColors.error,
        action: TextButton.icon(
          onPressed: _isLoading ? null : _search,
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
        ),
      );
    }

    final results = _results;
    if (results == null) {
      return _buildMessage(
        icon: Icons.menu_book_outlined,
        title: 'Sua próxima leitura está por aí',
        message: 'Digite pelo menos 2 caracteres e toque em buscar.',
        color: AppColors.primary,
      );
    }

    if (results.isEmpty) {
      return _buildMessage(
        icon: Icons.search_off,
        title: 'Nenhum livro encontrado',
        message: 'Tente outro título ou confira a grafia do autor.',
        color: AppColors.secondary,
      );
    }

    return StreamBuilder<List<BookModel>>(
      stream: _booksStream,
      builder: (context, snapshot) {
        final savedBooks = {
          for (final book in snapshot.data ?? [])
            if (book.googleBooksId.isNotEmpty) book.googleBooksId: book,
        };

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final book = results[index];
            final savedBook = savedBooks[book.googleBooksId];
            final isAdding = _addingBookIds.contains(book.googleBooksId);
            return _buildBookResult(
              book,
              savedBook,
              isAdding,
              theme,
            );
          },
        );
      },
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Literata',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 12),
              action,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookResult(
    BookModel book,
    BookModel? savedBook,
    bool isAdding,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 68,
              height: 102,
              color: AppColors.secondaryContainer,
              child: book.thumbnailUrl.isEmpty
                  ? const Icon(
                      Icons.menu_book,
                      color: AppColors.secondary,
                    )
                  : Image.network(
                      book.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.menu_book,
                        color: AppColors.secondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Literata',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.authorsDisplay,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.safePageCount > 0
                      ? '${book.safePageCount} páginas'
                      : 'Número de páginas indisponível',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                if (savedBook != null)
                  Chip(
                    label: Text('Na estante: ${savedBook.status.label}'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.primaryFixed,
                    labelStyle: const TextStyle(color: AppColors.primary),
                    side: BorderSide.none,
                  )
                else
                  PopupMenuButton<BookStatus>(
                    tooltip: 'Escolher estante',
                    enabled: !isAdding && book.googleBooksId.isNotEmpty,
                    onSelected: (status) => _addBook(book, status),
                    itemBuilder: (context) => BookStatus.values
                        .map(
                          (status) => PopupMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAdding)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            const Icon(
                              Icons.add,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          const SizedBox(width: 6),
                          Text(
                            'Adicionar à estante',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
