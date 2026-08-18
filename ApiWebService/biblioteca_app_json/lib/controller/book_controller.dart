import 'package:biblioteca_app_json/model/book_model.dart';
import 'package:biblioteca_app_json/service/api_service.dart';

class BookController {
  // Métodos
  // Ler
  Future<List<BookModel>> fetchAll() async {
    final list = await ApiService.getList("books");
    return list.map<BookModel>((item) => BookModel.fromMap(item)).toList();
  }

  // Ler um livro por vez
  Future<BookModel> fetchOne(String id) async {
    final book = await ApiService.getOne("books", id);
    return BookModel.fromMap(book);
  }

  // Criar
  Future<BookModel> create(BookModel b) async {
    final created = await ApiService.post("books", b.toMap());
    return BookModel.fromMap(created);
  }

  // Atualizar
  Future<BookModel> update(BookModel b) async {
    final updated = await ApiService.put("books", b.toMap(), b.id!);
    return BookModel.fromMap(updated);
  }

  //Deletar
  Future<void> delete(String id) async {
    await ApiService.delete("books", id);
  }
}
