import 'package:flutter/material.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/profile_controller.dart';
import 'favorites_screen.dart';
import 'login_profile_screen.dart';
import 'search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ProfileController profileController;
  final FavoritesController favoritesController;

  const MainNavigationScreen({
    super.key,
    required this.profileController,
    required this.favoritesController,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Reage dinamicamente a qualquer alteração de estado no perfil do usuário
    widget.profileController.addListener(_onProfileChanged);
    _onProfileChanged();
  }

  @override
  void dispose() {
    widget.profileController.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final user = widget.profileController.currentUser;
    if (user != null) {
      widget.favoritesController.loadFavorites(user.id);
    } else {
      widget.favoritesController.clearFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      SearchScreen(
        profileController: widget.profileController,
        favoritesController: widget.favoritesController,
      ),
      FavoritesScreen(
        profileController: widget.profileController,
        favoritesController: widget.favoritesController,
      ),
      LoginProfileScreen(
        profileController: widget.profileController,
        favoritesController: widget.favoritesController,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}