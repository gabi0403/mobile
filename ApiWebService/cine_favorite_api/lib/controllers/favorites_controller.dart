import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/movie.dart';

class FavoritesController extends ChangeNotifier {
  List<Movie> _favorites = [];
  bool _isLoading = false;

  List<Movie> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites(String userId) async {
    if (userId.isEmpty) {
      _favorites = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await DatabaseHelper.instance.getFavoritesByUser(userId);
    } catch (e) {
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }

  Future<bool> addFavorite(Movie movie, String userId) async {
    if (userId.isEmpty) return false;
    if (isFavorite(movie.id, movie.mediaType)) return false;

    try {
      await DatabaseHelper.instance.insertFavorite(movie, userId);
      _favorites = await DatabaseHelper.instance.getFavoritesByUser(userId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(int id, String mediaType, String userId) async {
    if (userId.isEmpty) return false;

    try {
      final rowsAffected = await DatabaseHelper.instance.removeFavorite(id, mediaType, userId);
      if (rowsAffected > 0) {
        _favorites.removeWhere((item) => item.id == id && item.mediaType == mediaType);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRating(int id, String mediaType, String userId, double newRating) async {
    if (userId.isEmpty) return false;

    try {
      final rowsAffected = await DatabaseHelper.instance.updateUserRating(id, mediaType, userId, newRating);
      if (rowsAffected > 0) {
        _favorites = await DatabaseHelper.instance.getFavoritesByUser(userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool isFavorite(int id, String mediaType) {
    return _favorites.any((item) => item.id == id && item.mediaType == mediaType);
  }
}