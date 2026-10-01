import 'package:flutter/material.dart';

import 'models/local_user.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class RegistroPontoApp extends StatelessWidget {
  const RegistroPontoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF126B5B),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Registro de Ponto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F6F1),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F6F1),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE1E5DF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  LocalUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      _user = await LocalAuthService.instance.currentUser();
    } catch (_) {
      _user = null;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onAuthenticated(LocalUser user) => setState(() => _user = user);

  Future<void> _signOut() async {
    await LocalAuthService.instance.signOut();
    if (mounted) setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = _user;
    return user == null
        ? AuthScreen(onAuthenticated: _onAuthenticated)
        : HomeScreen(user: user, onSignOut: _signOut);
  }
}
