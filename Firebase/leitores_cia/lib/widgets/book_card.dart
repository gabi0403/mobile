import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/book_model.dart';

/// Card de exibição horizontal de um livro na estante digital.
/// Segue a especificação visual do DESIGN.md:
/// - Capa com proporção aproximada de 2:3 e cantos arredondados de 8px
/// - Tipografia Literata para o título e Plus Jakarta Sans para metadados
/// - Tag pill-shape para o status atual
/// - Menu de ações contextuais para transição de status (RF-08) e exclusão (RF-09)
class BookCard extends StatelessWidget {
  final BookModel book;
  final ValueChanged<BookStatus>? onStatusChanged;
  final VoidCallback? onDelete;

  const BookCard({
    super.key,
    required this.book,
    this.onStatusChanged,
    this.onDelete,
  });

  Color _getStatusBgColor(BookStatus status) {
    switch (status) {
      case BookStatus.lendo:
        return const Color(0xFFC2EDCB); // Verde menta suave
      case BookStatus.queroLer:
        return const Color(0xFFEADBCE); // Terracota claro
      case BookStatus.lidos:
        return AppColors.primaryContainer;
    }
  }

  Color _getStatusTextColor(BookStatus status) {
    switch (status) {
      case BookStatus.lendo:
        return AppColors.primary;
      case BookStatus.queroLer:
        return AppColors.tertiary;
      case BookStatus.lidos:
        return AppColors.onPrimaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceContainerHigh.withAlpha(80),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A3B32).withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Capa do livro (proporção ~2:3)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 68,
                height: 102,
                color: AppColors.secondaryContainer,
                child: book.thumbnailUrl.isNotEmpty
                    ? Image.network(
                        book.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildCoverPlaceholder(),
                      )
                    : _buildCoverPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),

            // Informações textuais da obra
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título da obra
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Autores
                  Text(
                    book.authorsDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadados adicionais: páginas e status
                  Row(
                    children: [
                      // Badge de páginas
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          book.safePageCount > 0
                              ? '${book.safePageCount} págs'
                              : 'Pág. n/d',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Badge de status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(book.status),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          book.status.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusTextColor(book.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu de ações (3 pontos)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.secondary,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.surface,
              onSelected: (value) {
                if (value == 'DELETE') {
                  onDelete?.call();
                } else if (value.startsWith('STATUS_')) {
                  final statusStr = value.replaceFirst('STATUS_', '');
                  final newStatus = BookStatus.fromString(statusStr);
                  onStatusChanged?.call(newStatus);
                }
              },
              itemBuilder: (context) {
                final items = <PopupMenuEntry<String>>[];

                // Opções de mudança de status para as outras estantes
                for (final status in BookStatus.values) {
                  if (status != book.status) {
                    items.add(
                      PopupMenuItem<String>(
                        value: 'STATUS_${status.firestoreValue}',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Mover para "${status.label}"',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }

                items.add(const PopupMenuDivider());

                // Opção de exclusão
                items.add(
                  PopupMenuItem<String>(
                    value: 'DELETE',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        const Flexible(
                          child: Text(
                            'Remover da Estante',
                            style: TextStyle(color: AppColors.error),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                return items;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryContainer,
            AppColors.surfaceContainerHigh,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.auto_stories,
          color: AppColors.secondary,
          size: 28,
        ),
      ),
    );
  }
}
