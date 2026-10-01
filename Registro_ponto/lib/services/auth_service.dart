import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../models/local_user.dart';
import 'local_database.dart';

class LocalAuthException implements Exception {
  const LocalAuthException(this.message);

  final String message;
}

class LocalAuthService {
  LocalAuthService._();

  static final instance = LocalAuthService._();
  static final _passwordKdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  final _database = LocalDatabase.instance;

  Future<LocalUser?> currentUser() => _database.currentUser();

  Future<LocalUser> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final passwordHash = await _hashPassword(password, salt);
    try {
      return await _database.createUser(
        email: normalizedEmail,
        passwordSalt: base64Encode(salt),
        passwordHash: passwordHash,
      );
    } on LocalDatabaseException catch (error) {
      if (error.code == LocalDatabaseError.emailAlreadyExists) {
        throw const LocalAuthException('Este e-mail já possui uma conta.');
      }
      rethrow;
    }
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final credentials = await _database.userCredentials(
      email.trim().toLowerCase(),
    );
    if (credentials == null) {
      throw const LocalAuthException('E-mail ou senha incorretos.');
    }
    final salt = base64Decode(credentials['password_salt']! as String);
    final expectedHash = base64Decode(credentials['password_hash']! as String);
    final actualHash = base64Decode(await _hashPassword(password, salt));
    var difference = expectedHash.length ^ actualHash.length;
    for (var index = 0; index < expectedHash.length; index++) {
      difference |= expectedHash[index] ^ actualHash[index];
    }
    if (difference != 0) {
      throw const LocalAuthException('E-mail ou senha incorretos.');
    }

    final user = LocalUser(
      id: credentials['id']! as int,
      email: credentials['email']! as String,
    );
    await _database.setSession(user.id);
    return user;
  }

  Future<void> signOut() => _database.clearSession();

  Future<String> _hashPassword(String password, List<int> salt) async {
    final key = await _passwordKdf.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return base64Encode(await key.extractBytes());
  }
}
