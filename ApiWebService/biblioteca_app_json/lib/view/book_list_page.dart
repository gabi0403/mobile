import 'package:biblioteca_app_json/controller/book_controller.dart';
import 'package:flutter/material.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  //Controlador das Mudanças na base de dados (criação /Atualização/ delete)
  final ValueNotifier<int> _notifier = ValueNotifier<int>(0);
  //chama a classe de controller de Livros
  final BookController _bookController = BookController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, _, __) {
          return FutureBuilder(
            future: _bookController.fetchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      //Botão para REcarregar
                    ],
                  ),
                );
              }
              final books = snapshot.data ?? [];
              if (books.isEmpty) {
                return Center(child: Text("Nenhum Livro na Lista"));
              }
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return Card();
                },
              );
            },
          );
        },
      ),
    );
  }
}
