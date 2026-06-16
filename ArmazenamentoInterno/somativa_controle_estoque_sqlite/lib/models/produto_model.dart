class ProdutoModel {
  int? id;
  String nome;
  String? descricao;
  double precoCusto;
  double precoVenda;
  int quantidadeAtual;
  String codigo;

  ProdutoModel({
    this.id,
    required this.nome,
    this.descricao,
    required this.precoCusto,
    required this.precoVenda,
    required this.quantidadeAtual,
    required this.codigo,
  });

  // Converte objeto para Map (para inserir/atualizar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco_custo': precoCusto,
      'preco_venda': precoVenda,
      'quantidade_atual': quantidadeAtual,
      'codigo': codigo,
    };
  }

  // Cria objeto a partir de um Map (para ler do SQLite)
  factory ProdutoModel.fromMap(Map<String, dynamic> map) {
    return ProdutoModel(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      precoCusto: map['preco_custo'],
      precoVenda: map['preco_venda'],
      quantidadeAtual: map['quantidade_atual'],
      codigo: map['codigo'],
    );
  }
}