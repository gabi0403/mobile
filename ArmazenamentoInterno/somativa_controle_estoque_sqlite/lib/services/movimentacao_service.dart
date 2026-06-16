import '../models/movimentacao_model.dart';
import '../models/produto_model.dart';
import 'database_helper.dart';

class MovimentacaoService {
  final dbHelper = DatabaseHelper.instancia;

  Future<void> registrarMovimentacao(MovimentacaoModel mov) async {
    final db = await dbHelper.banco;

    // Inicia uma transação segura
    await db.transaction((txn) async {
      // 1. Busca os dados atuais do produto
      final queryProduto = await txn.query(
        'produtos',
        where: 'id = ?',
        whereArgs: [mov.produtoId],
      );

      if (queryProduto.isEmpty) {
        throw Exception('Produto não encontrado no banco de dados.');
      }

      final produto = ProdutoModel.fromMap(queryProduto.first);
      int novaQuantidade = produto.quantidadeAtual;

      // 2. Aplica a regra de negócio
      if (mov.tipo == 'SAIDA') {
        if (mov.quantidade > novaQuantidade) {
          throw Exception('Estoque insuficiente para esta saída.');
        }
        novaQuantidade -= mov.quantidade;
      } else if (mov.tipo == 'ENTRADA') {
        novaQuantidade += mov.quantidade;
      }

      // 3. Atualiza a quantidade do produto
      await txn.update(
        'produtos',
        {'quantidade_atual': novaQuantidade},
        where: 'id = ?',
        whereArgs: [produto.id],
      );

      // 4. Salva o registro da movimentação
      await txn.insert('movimentacoes', mov.toMap());
    });
  }

  Future<List<MovimentacaoModel>> listarPorProduto(int produtoId) async {
    final db = await dbHelper.banco;
    final List<Map<String, dynamic>> mapas = await db.query(
      'movimentacoes',
      where: 'produto_id = ?',
      whereArgs: [produtoId],
      orderBy: 'id DESC', // Traz as mais recentes primeiro
    );
    return mapas.map((mapa) => MovimentacaoModel.fromMap(mapa)).toList();
  }
}