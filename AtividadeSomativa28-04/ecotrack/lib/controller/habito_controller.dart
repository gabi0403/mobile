import 'package:flutter/material.dart';
import '../model/habito.dart';

class HabitoController extends ChangeNotifier {
  // Lista de hábitos (final pois a lista em si não muda, apenas os itens dentro dela)
  final List<Habito> _habitos = [
    Habito(titulo: "Separar lixo reciclável", pontos: 20),
    Habito(titulo: "Economizar água no banho", pontos: 15),
    Habito(titulo: "Usar garrafa reutilizável", pontos: 10),
    Habito(titulo: "Desligar luzes extras", pontos: 5),
    Habito(titulo: "Usar transporte público", pontos: 25),
  ];

  // Variável para o Modo Escuro (opcional)
  bool _modoEscuro = false;
  bool get modoEscuro => _modoEscuro;

  // Getters para as listas filtradas
  List<Habito> get habitosPendentes => _habitos.where((h) => !h.concluido).toList();
  List<Habito> get habitosConcluidos => _habitos.where((h) => h.concluido).toList();

  // Função para alternar o tema e avisar o app todo
  void alternarTema() {
    _modoEscuro = !_modoEscuro;
    notifyListeners();
  }

  // Marcar hábito como pronto
  void concluirHabito(Habito habito) {
    habito.concluido = true;
    notifyListeners();
  }

  // Limpar o progresso (configurações)
  void reiniciarProgresso() {
    for (var h in _habitos) {
      h.concluido = false;
    }
    notifyListeners();
  }

  // Métricas do Dashboard
  int get totalConcluidos => habitosConcluidos.length;
  int get totalPendentes => habitosPendentes.length;
  
  int get pontuacaoTotal {
    int soma = 0;
    for (var h in habitosConcluidos) {
      soma += h.pontos;
    }
    return soma;
  }

  double get progressoMeta => _habitos.isEmpty ? 0 : totalConcluidos / _habitos.length;

  // Nível atual do usuário
  String get nivelUsuario {
    if (totalConcluidos < 2) return "Eco-Iniciante";
    if (totalConcluidos < 4) return "Eco-Aprendiz";
    return "Eco-Guerreiro";
  }

  // Impacto estimado (ex: cada ponto = 0.1kg de CO2 evitado)
  String get impactoEstimado => "${(pontuacaoTotal * 0.1).toStringAsFixed(1)} kg CO2";
}