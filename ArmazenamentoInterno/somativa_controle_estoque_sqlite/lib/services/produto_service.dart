import '../models/produto_model.dart';
import 'database_helper.dart';

class ProdutoService {
  final dbHelper = DatabaseHelper.instancia;

  Future<int> cadastrarProduto(ProdutoModel produto) async {
    final db = await dbHelper.banco;
    return await db.insert('produtos', produto.toMap());
  }

  Future<List<ProdutoModel>> listarProdutos() async {
    final db = await dbHelper.banco;
    final List<Map<String, dynamic>> mapas = await db.query('produtos');
    return mapas.map((mapa) => ProdutoModel.fromMap(mapa)).toList();
  }

  Future<int> excluirProduto(int id) async {
    final db = await dbHelper.banco;
    return await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }
}