//Modelagem dos Dados

class Tarefa {
  //atributos
  String titulo; //armazena o titulo da tarefa
  bool concluida; //status da Tarefa
  //classe que armazena informações de data
  DateTime dataCriacao;

  //construtor padrão
  // Tarefa(String titulo){
  //   this.titulo = titulo;
  //   this.concluida = false;
  //   this.criacao = DateTime.now();
  // }

  //construtor resumido
  Tarefa({
    required this.titulo,
    this.concluida = false,
    DateTime? dataCriacao,}) : dataCriacao = dataCriacao ?? DateTime.now();
    //se data de criação for nulo, atribui uma data DateTime.now() -> pega a data atual

  //classe de modelage de dados, toda tarefa criada é um obj da classe Tarefa
  //toda tarefa tem um titulo, um status de conclusão e uma data de criação

}