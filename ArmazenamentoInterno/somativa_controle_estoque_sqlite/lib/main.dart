import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/produto_controller.dart';
import 'controllers/movimentacao_controller.dart';
import 'controllers/theme_controller.dart';
import 'views/lista_produtos_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProdutoController()),
        ChangeNotifierProvider(create: (_) => MovimentacaoController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: const MeuAplicativo(),
    ),
  );
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          title: 'Controle de Estoque',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: themeController.themeMode,
          home: const ListaProdutosView(),
        );
      },
    );
  }
}
