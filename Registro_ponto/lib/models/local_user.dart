class LocalUser {
  const LocalUser({required this.id, required this.email});

  final int id;
  final String email;

  String get uid => id.toString();
}
