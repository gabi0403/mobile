import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/book_service.dart';

class StatsScreen extends StatefulWidget {
  final String userId;
  final BookService bookService;

  const StatsScreen({
    super.key,
    required this.userId,
    required this.bookService,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Stream<Map<String, dynamic>?> _statsStream;

  @override
  void initState() {
    super.initState();
    _statsStream = widget.bookService.streamReadingStats(widget.userId);
  }

  void _retry() {
    setState(() {
      _statsStream = widget.bookService.streamReadingStats(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<Map<String, dynamic>?>(
      stream: _statsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildMessage(
            theme: theme,
            icon: Icons.cloud_off,
            title: 'Não foi possível carregar suas estatísticas',
            message: 'Verifique sua conexão e tente novamente.',
            action: TextButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          );
        }

        final stats = snapshot.data;
        if (stats == null) {
          return _buildMessage(
            theme: theme,
            icon: Icons.auto_graph,
            title: 'Sua jornada está começando',
            message:
                'Quando a Cloud Function atualizar seu resumo, os livros e páginas lidos aparecerão aqui.',
          );
        }

        final totalBooksRead = stats['totalBooksRead'];
        final totalPagesRead = stats['totalPagesRead'];
        if (totalBooksRead is! num ||
            !totalBooksRead.isFinite ||
            totalBooksRead < 0 ||
            totalPagesRead is! num ||
            !totalPagesRead.isFinite ||
            totalPagesRead < 0) {
          return _buildMessage(
            theme: theme,
            icon: Icons.error_outline,
            title: 'Dados de estatísticas inválidos',
            message:
                'Não foi possível interpretar o resumo recebido. Tente novamente mais tarde.',
          );
        }

        return _buildStats(
          theme,
          totalBooksRead.toInt(),
          totalPagesRead.toInt(),
        );
      },
    );
  }

  Widget _buildStats(ThemeData theme, int totalBooksRead, int totalPagesRead) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jornada Literária',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Literata',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seu caderno de leituras',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_stories,
                  color: AppColors.onPrimary,
                  size: 28,
                ),
                const SizedBox(height: 16),
                Text(
                  'Livros concluídos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                Text(
                  '$totalBooksRead',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontFamily: 'Literata',
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Páginas lidas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        '$totalPagesRead',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Literata',
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Literata',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
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
}
