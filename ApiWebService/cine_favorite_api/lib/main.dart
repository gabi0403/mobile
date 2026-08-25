import 'package:flutter/material.dart';
import 'controllers/favorites_controller.dart';
import 'controllers/profile_controller.dart';
import 'views/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CineFavoriteApp());
}

class CineFavoriteApp extends StatefulWidget {
  const CineFavoriteApp({super.key});

  @override
  State<CineFavoriteApp> createState() => _CineFavoriteAppState();
}

class _CineFavoriteAppState extends State<CineFavoriteApp> {
  late final ProfileController _profileController;
  late final FavoritesController _favoritesController;

  @override
  void initState() {
    super.initState();
    _profileController = ProfileController();
    _favoritesController = FavoritesController();
  }

  @override
  void dispose() {
    _profileController.dispose();
    _favoritesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineFavorite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainNavigationScreen(
        profileController: _profileController,
        favoritesController: _favoritesController,
      ),
    );
  }
}