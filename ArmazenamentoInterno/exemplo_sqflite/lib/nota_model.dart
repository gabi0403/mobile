//modelagem de dados 

class Nota {
  //atributos
  final int? id; // permitir que a variável seja nula
  //em um primeiro momento a variável é nula
  // somente quando cair no DB irá receber um valor para o ID

  final String titulo;
  final String conteudo;

  //construtor
  Nota({this.id, required this.titulo, required this.conteudo});

  //métodos de serialização de dados (ToMap() fromMap())

  //toMap() -> converter um obj da Classe Nota para MAP de DB (inserir dados no DB)

  Map<String,dynamic> toMap(){
    return{
      "id":id, // mapeando as colunas com DB com os atributos da classe
      "titulo":titulo,
      "conteudo":conteudo
    };
  }

  // converter um MAP(vindo do DB) -> obj da classe Nota
  // para fazer o from vamos usar um factory
  factory Nota.fromMap(Map<String, dynamic> map){
    return Nota(
      id: map ["id"] as int, //se está voltando do DB então já tem um ID
      titulo: map ["titulo"] as String,
      conteudo: map ["conteudo"] as String,
    );
  }


  //método para imprimir dados
  @override
  String toString() {
    return "Nota{id:$id, título: $titulo, conteúdo: $conteudo}";
  }

  
}