import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
      );
}

class ProfileService {
  static const String _activeUserKey = 'active_user_id';
  static const String _savedProfilesKey = 'all_saved_profiles';

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profiles = await getSavedProfiles();

    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }

    final encodedList = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await prefs.setString(_savedProfilesKey, encodedList);
    await prefs.setString(_activeUserKey, profile.id);
  }

  static Future<List<UserProfile>> getSavedProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedProfilesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((j) => UserProfile.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<UserProfile?> getActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    final activeId = prefs.getString(_activeUserKey);
    if (activeId == null || activeId.isEmpty) {
      return null;
    }
    final profiles = await getSavedProfiles();
    try {
      return profiles.firstWhere((p) => p.id == activeId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setActiveUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, id);
  }

  static Future<void> clearActiveUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }

  static Future<void> clearProfile() async {
    await clearActiveUser();
  }
}