import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

/// Porta de entrada reativa que gerencia a transição entre telas públicas e autenticadas.
/// Aceita implementações alternativas de [AuthService] e [BookService] para testes.
class AuthGate extends StatelessWidget {
  final AuthService? authService;
  final BookService? bookService;

  const AuthGate({super.key, this.authService, this.bookService});

  @override
  Widget build(BuildContext context) {
    final effectiveAuthService = authService ?? AuthService();

    return StreamBuilder<User?>(
      initialData: effectiveAuthService.currentUser,
      stream: effectiveAuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(
            authService: effectiveAuthService,
            bookService: bookService,
          );
        }

        return LoginScreen(authService: effectiveAuthService);
      },
    );
  }
}
