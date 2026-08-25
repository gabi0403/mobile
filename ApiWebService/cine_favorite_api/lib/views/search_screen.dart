import 'package:flutter/material.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class SearchScreen extends StatefulWidget {
  final ProfileController profileController;
  final FavoritesController favoritesController;

  const SearchScreen({
    super.key,
    required this.profileController,
    required this.favoritesController,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await TmdbService.searchAll(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(Movie movie) async {
    final user = widget.profileController.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crie um perfil antes de salvar favoritos.')),
      );
      return;
    }

    final isFav = widget.favoritesController.isFavorite(movie.id, movie.mediaType);

    if (isFav) {
      await widget.favoritesController.removeFavorite(movie.id, movie.mediaType, user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${movie.title} removido dos favoritos.')),
      );
    } else {
      final added = await widget.favoritesController.addFavorite(movie, user.id);
      if (!mounted) return;
      if (added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${movie.title} adicionado aos favoritos!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Filmes e Séries')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Digite o título...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_searchResults.isEmpty)
              const Expanded(
                child: Center(child: Text('Nenhum resultado encontrado.')),
              )
            else
              Expanded(
                child: ListenableBuilder(
                  listenable: widget.favoritesController,
                  builder: (context, _) {
                    return ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final movie = _searchResults[index];
                        final isFav = widget.favoritesController.isFavorite(movie.id, movie.mediaType);

                        return ListTile(
                          leading: movie.fullPosterUrl.isNotEmpty
                              ? Image.network(
                                  movie.fullPosterUrl,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(Icons.movie),
                                )
                              : const Icon(Icons.movie),
                          title: Text(movie.title),
                          subtitle: Text(
                            '${movie.mediaType == 'movie' ? 'Filme' : 'Série'} • TMDB: ${movie.tmdbRating.toStringAsFixed(1)}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : null,
                            ),
                            onPressed: () => _toggleFavorite(movie),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}