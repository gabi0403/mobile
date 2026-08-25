import 'package:flutter/material.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/movie.dart';

class FavoritesScreen extends StatelessWidget {
  final ProfileController profileController;
  final FavoritesController favoritesController;

  const FavoritesScreen({
    super.key,
    required this.profileController,
    required this.favoritesController,
  });

  void _showRatingDialog(BuildContext context, Movie movie) {
    final user = profileController.currentUser;
    if (user == null) return;

    final controller = TextEditingController(text: movie.userRating.toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Avaliar "${movie.title}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Sua nota (0.0 a 10.0)'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.dispose();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final rating = double.tryParse(controller.text);

              if (rating == null || rating < 0.0 || rating > 10.0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('A nota deve estar entre 0 e 10.')),
                );
                return;
              }

              // 1. Desmonta o diálogo primeiro
              Navigator.of(dialogContext).pop();

              // 2. Aguarda a transição do diálogo terminar totalmente
              await Future.delayed(const Duration(milliseconds: 150));

              // 3. Atualiza o banco e notifica a tela quando a rota já fechou
              await favoritesController.updateRating(
                movie.id,
                movie.mediaType,
                user.id,
                rating,
              );

              controller.dispose();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: profileController,
      builder: (context, _) {
        final user = profileController.currentUser;

        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Faça login para ver sua galeria de favoritos.'),
            ),
          );
        }

        return ListenableBuilder(
          listenable: favoritesController,
          builder: (context, _) {
            final favorites = favoritesController.favorites;

            return Scaffold(
              appBar: AppBar(title: Text('Favoritos de ${user.name}')),
              body: favoritesController.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favorites.isEmpty
                      ? const Center(child: Text('Nenhum favorito salvo ainda.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final movie = favorites[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: movie.fullPosterUrl.isNotEmpty
                                            ? Image.network(
                                                movie.fullPosterUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.movie, size: 50),
                                              )
                                            : const Icon(Icons.movie, size: 50),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              movie.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text('Sua Nota: ${movie.userRating.toStringAsFixed(1)}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await favoritesController.removeFavorite(
                                          movie.id,
                                          movie.mediaType,
                                          user.id,
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.star, color: Colors.amber),
                                      onPressed: () => _showRatingDialog(context, movie),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            );
          },
        );
      },
    );
  }
}