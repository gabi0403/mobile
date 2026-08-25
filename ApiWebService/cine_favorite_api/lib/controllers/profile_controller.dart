import 'package:flutter/material.dart';
import '../services/profile_service.dart';

export '../services/profile_service.dart' show UserProfile;

class ProfileController extends ChangeNotifier {
  UserProfile? _currentUser;
  List<UserProfile> _savedProfiles = [];
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  List<UserProfile> get savedProfiles => _savedProfiles;
  bool get isLoading => _isLoading;

  ProfileController() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _savedProfiles = await ProfileService.getSavedProfiles();
    _currentUser = await ProfileService.getActiveUser();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(String name, String avatarUrl) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    _savedProfiles = await ProfileService.getSavedProfiles();

    String userId;
    String finalAvatarUrl = avatarUrl.trim();

    if (_currentUser != null) {
      userId = _currentUser!.id;
      if (finalAvatarUrl.isEmpty) {
        finalAvatarUrl = _currentUser!.avatarUrl;
      }
    } else {
      final existingIndex = _savedProfiles.indexWhere(
        (p) => p.name.trim().toLowerCase() == trimmedName.toLowerCase(),
      );

      if (existingIndex >= 0) {
        final existing = _savedProfiles[existingIndex];
        userId = existing.id;
        if (finalAvatarUrl.isEmpty) {
          finalAvatarUrl = existing.avatarUrl;
        }
      } else {
        userId = DateTime.now().millisecondsSinceEpoch.toString();
      }
    }

    final profile = UserProfile(
      id: userId,
      name: trimmedName,
      avatarUrl: finalAvatarUrl,
    );

    await ProfileService.saveProfile(profile);
    _currentUser = profile;
    _savedProfiles = await ProfileService.getSavedProfiles();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> selectProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();

    await ProfileService.setActiveUser(profile.id);
    _currentUser = profile;

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    await ProfileService.clearActiveUser();
    _currentUser = null;
    _savedProfiles = await ProfileService.getSavedProfiles();

    _isLoading = false;
    notifyListeners();
    return true;
  }
}