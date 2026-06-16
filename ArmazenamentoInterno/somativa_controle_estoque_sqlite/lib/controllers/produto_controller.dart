import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../services/produto_service.dart';

class ProdutoController extends ChangeNotifier {
  final ProdutoService _service = ProdutoService();

  List<ProdutoModel> produtos = [];
  bool carregando = false;
  String erro = '';

  Future<void> carregarProdutos() async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      produtos = await _service.listarProdutos();
    } catch (e) {
      erro = 'Erro ao carregar produtos: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> salvarProduto(ProdutoModel produto) async {
    try {
      await _service.cadastrarProduto(produto);
      await carregarProdutos(); // Atualiza a lista após salvar
      return true;
    } catch (e) {
      erro = 'Erro ao salvar produto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> excluirProduto(int id) async {
    try {
      await _service.excluirProduto(id);
      await carregarProdutos();
      return true;
    } catch (e) {
      erro = 'Erro ao excluir produto: $e';
      notifyListeners();
      return false;
    }
  }
}
