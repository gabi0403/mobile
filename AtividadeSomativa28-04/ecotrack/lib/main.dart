import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/habito_controller.dart';
import 'view/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HabitoController(),
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o controller para mudar o tema
    final controller = Provider.of<HabitoController>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //Configuração do tema claro/escuro
      themeMode: controller.modoEscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(primarySwatch: Colors.green, brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      home: const TelaInicial(),
    );
  }
}