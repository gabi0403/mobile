import 'package:firebase_auth/firebase_auth.dart';

/// Serviço gerenciador de autenticação com Firebase Authentication.
/// Responsável por login, cadastro, logout e observação do estado da sessão.
class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Stream que emite alterações no estado de autenticação do usuário.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Retorna o usuário atualmente autenticado ou null se não houver sessão ativa.
  User? get currentUser => _auth.currentUser;

  /// Realiza login utilizando e-mail e senha.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Ocorreu um erro inesperado ao realizar login. Tente novamente.';
    }
  }

  /// Cria uma nova conta de usuário com e-mail e senha.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'Ocorreu um erro inesperado ao cadastrar. Tente novamente.';
    }
  }

  /// Encerra com segurança a sessão ativa do usuário.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Erro ao encerrar sessão. Tente novamente.';
    }
  }

  /// Mapeia os códigos de erro do Firebase Authentication para mensagens amigáveis em português.
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos. Verifique suas credenciais.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado em outra conta.';
      case 'invalid-email':
        return 'O formato do e-mail informado é inválido.';
      case 'weak-password':
        return 'A senha é muito fraca. Ela deve conter no mínimo 6 caracteres.';
      case 'user-disabled':
        return 'Esta conta de usuário foi temporariamente desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas consecutivas. Aguarde alguns instantes e tente novamente.';
      case 'network-request-failed':
        return 'Falha de conexão com a internet. Verifique sua rede e tente novamente.';
      default:
        return e.message ?? 'Falha na autenticação. Tente novamente mais tarde.';
    }
  }
}
