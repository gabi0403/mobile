class UserProfile {
  final String id;
  final String name;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  // Converte o objeto para Map (preparação para serialização em JSON String no SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  // Cria o objeto a partir de um Map (obtido via deserialização de JSON String do SharedPreferences)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}