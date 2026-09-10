import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lista_tarefas_provider/model/tarefa.dart';
import 'package:path_provider/path_provider.dart';

class TarefaController extends ChangeNotifier {
  TarefaController() {
    _carregarTarefas();
  }

  bool _carregando = true;

  bool get carregando => _carregando;

  //ChanceNotifier -> classe do provider
  //TArefas Controller esta herdando elementos da ChanceNotifier
  //herda o método notifierListener()

  //atributos
  //lista para armazer as tarefas criadas
  List<Tarefa> _tarefas = []; //atributo privado

  //getter -=-> listar as tarefas (read)
  List<Tarefa> get tarefas => _tarefas;
  //método get para acessar os dados da lista privada

  Future<File> _getArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File('${diretorio.path}/tarefas.json');
  }

  Future<void> _carregarTarefas() async {
    try {
      final arquivo = await _getArquivo();
      if (await arquivo.exists()) {
        final conteudo = await arquivo.readAsString();
        final dados = jsonDecode(conteudo) as List<dynamic>;
        _tarefas = dados
            .map((item) => Tarefa.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Erro ao ler tarefas: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> _salvarTarefas() async {
    try {
      final arquivo = await _getArquivo();
      await arquivo.writeAsString(
        jsonEncode(_tarefas.map((tarefa) => tarefa.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Erro ao salvar tarefas: $e');
    }
  }

  //métodos Crud
  //adicionar tarefa (create)
  void criarTarefa(String titulo) {
    //verificar se o texto não é vazio
    if (titulo.trim().isEmpty) return; //interrompe o método

    _tarefas.add(Tarefa(titulo: titulo.trim()));

    //avisa os listeners
    //atualiza os widgets que usar esse dado
    notifyListeners();
    _salvarTarefas();
  }

  //alterar tarefa (update)
  void alterarTarefa(int index) {
    //inverter o valor da booleana "!"
    _tarefas[index].concluida = !_tarefas[index].concluida;
    notifyListeners();
    _salvarTarefas();
  }

  //remover tarefa (delete)
  void removerTarefa(int index) {
    //void => função que não tem return
    //busca a tarefa e remove da lista
    _tarefas.removeAt(index);
    notifyListeners();
    _salvarTarefas();
  }

  // criar métricas para usar no DashboardPage
  //Calcular o Total de Tarefas
  // calcula quantas tarefas tem no vetor
  int get totalTarefas => _tarefas.length;

  //Total de Tarefas Concluídas
  int get totalTarefasConcluidas =>
      _tarefas.where((tarefa) => tarefa.concluida).length;

  //Total de Tarefas Pendentes
  int get totalTarefasPendente =>
      _tarefas.where((tarefa) => !tarefa.concluida).length;

  //Porcentagem de Tarefas Concluidas
  double get porcentagemTarefasConcluidas {
    if (_tarefas.isEmpty) return 0;
    return (totalTarefasConcluidas / totalTarefas) * 100;
  }
}
