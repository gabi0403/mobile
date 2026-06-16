class MovimentacaoModel {
  int? id;
  int produtoId;
  String tipo; // 'ENTRADA' ou 'SAIDA'
  int quantidade;
  String data;
  String? observacao;

  MovimentacaoModel({
    this.id,
    required this.produtoId,
    required this.tipo,
    required this.quantidade,
    required this.data,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produto_id': produtoId,
      'tipo': tipo,
      'quantidade': quantidade,
      'data': data,
      'observacao': observacao,
    };
  }

  factory MovimentacaoModel.fromMap(Map<String, dynamic> map) {
    return MovimentacaoModel(
      id: map['id'],
      produtoId: map['produto_id'],
      tipo: map['tipo'],
      quantidade: map['quantidade'],
      data: map['data'],
      observacao: map['observacao'],
    );
  }
}