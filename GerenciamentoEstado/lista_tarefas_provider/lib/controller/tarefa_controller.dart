import 'package:flutter/material.dart';
import 'package:lista_tarefas_provider/model/tarefa.dart';


class TarefaController extends ChangeNotifier{
//ChanceNotifier -> classe do provider
//TArefas Controller esta herdando elementos da ChanceNotifier
//herda o método notifierListener()

//atributos
//lista para armazer as tarefas criadas
List<Tarefa> _tarefas = []; //atributo privado

//getter -=-> listar as tarefas (read)
List<Tarefa> get tarefas => _tarefas;
//método get para acessar os dados da lista privada

//métodos Crud
//adicionar tarefa (create)
void criarTarefa(String titulo){
  //verificar se o texto não é vazio
  if(titulo.trim().isEmpty) return; //interrompe o método

  _tarefas.add(Tarefa(titulo: titulo.trim()));

  //avisa os listeners
  //atualiza os widgets que usar esse dado
  notifyListeners();
}

//alterar tarefa (update)
void alterarTarefa(int index){
  //inverter o valor da booleana "!"
  _tarefas[index].concluida = !_tarefas[index].concluida;
  notifyListeners();
}

//remover tarefa (delete)
void removerTarefa(int index){
  //void => função que não tem return
  //busca a tarefa e remove da lista
  _tarefas.removeAt(index);
  notifyListeners();
}

// criar métricas para usar no DashboardPage
//Calcular o Total de Tarefas 
// calcula quantas tarefas tem no vetor
int get totalTarefas => _tarefas.length;

//Total de Tarefas Concluídas
int get totalTarefasConcluidas => _tarefas.where((tarefa)=>tarefa.concluida).length;

//Total de Tarefas Pendentes
int get totalTarefasPendente => _tarefas.where((tarefa)=>!tarefa.concluida).length;

//Porcentagem de Tarefas Concluidas
double get porcentagemTarefasConcluidas{
  if(_tarefas.isEmpty) return 0;
  return (totalTarefasConcluidas/totalTarefas)*100;
} 

}