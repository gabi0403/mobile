import 'package:flutter/material.dart';
import '../models/movimentacao_model.dart';
import '../services/movimentacao_service.dart';

class MovimentacaoController extends ChangeNotifier {
  final MovimentacaoService _service = MovimentacaoService();
  
  List<MovimentacaoModel> historico = [];
  bool carregando = false;
  String erro = '';

  Future<void> carregarHistorico(int produtoId) async {
    carregando = true;
    erro = '';
    notifyListeners();

    try {
      historico = await _service.listarPorProduto(produtoId);
    } catch (e) {
      erro = 'Erro ao carregar histórico: $e';
    } finally {
      carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarMovimentacao(MovimentacaoModel mov) async {
    try {
      await _service.registrarMovimentacao(mov);
      await carregarHistorico(mov.produtoId); // Atualiza o histórico
      return true;
    } catch (e) {
      // O erro do "Estoque insuficiente" lançado no Service será capturado aqui
      erro = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}