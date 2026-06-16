import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produto_model.dart';
import '../models/movimentacao_model.dart';
import '../controllers/movimentacao_controller.dart';
import '../controllers/produto_controller.dart';

class DetalhesProdutoView extends StatefulWidget {
  final ProdutoModel produto;
  const DetalhesProdutoView({super.key, required this.produto});

  @override
  State<DetalhesProdutoView> createState() => _DetalhesProdutoViewState();
}

class _DetalhesProdutoViewState extends State<DetalhesProdutoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovimentacaoController>().carregarHistorico(
        widget.produto.id!,
      );
    });
  }

  void _abrirDialogMovimentacao() {
    final qtdCtrl = TextEditingController();
    String tipoSelecionado = 'ENTRADA';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Movimentação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tipoSelecionado,
                items: const [
                  DropdownMenuItem(
                    value: 'ENTRADA',
                    child: Text('Entrada (Adicionar)'),
                  ),
                  DropdownMenuItem(
                    value: 'SAIDA',
                    child: Text('Saída (Remover)'),
                  ),
                ],
                onChanged: (valor) => tipoSelecionado = valor!,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextField(
                controller: qtdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final mov = MovimentacaoModel(
                  produtoId: widget.produto.id!,
                  tipo: tipoSelecionado,
                  quantidade: int.parse(qtdCtrl.text),
                  data: DateTime.now().toIso8601String(),
                );

                final sucesso = await context
                    .read<MovimentacaoController>()
                    .adicionarMovimentacao(mov);

                if (sucesso) {
                  // Atualiza a lista principal de produtos no fundo
                  if (context.mounted) {
                    context.read<ProdutoController>().carregarProdutos();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Movimentação registrada com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    final erro = context.read<MovimentacaoController>().erro;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(erro),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final detailsBackgroundColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.blue.shade50;
    final detailsTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(title: Text(widget.produto.nome)),
      body: Column(
        children: [
          // Área de Detalhes do Produto
          Container(
            padding: const EdgeInsets.all(16),
            color: detailsBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código: ${widget.produto.codigo}',
                      style: TextStyle(fontSize: 16, color: detailsTextColor),
                    ),
                    Text(
                      'Custo: R\$ ${widget.produto.precoCusto.toStringAsFixed(2)}',
                      style: TextStyle(color: detailsTextColor),
                    ),
                    Text(
                      'Venda: R\$ ${widget.produto.precoVenda.toStringAsFixed(2)}',
                      style: TextStyle(color: detailsTextColor),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _abrirDialogMovimentacao,
                  icon: const Icon(Icons.sync_alt),
                  label: const Text('Movimentar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Histórico de Movimentações',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),

          // Área de Histórico (ListView)
          Expanded(
            child: Consumer<MovimentacaoController>(
              builder: (context, controller, child) {
                if (controller.carregando)
                  return const Center(child: CircularProgressIndicator());
                if (controller.historico.isEmpty)
                  return const Center(
                    child: Text('Nenhuma movimentação registrada.'),
                  );

                return ListView.builder(
                  itemCount: controller.historico.length,
                  itemBuilder: (context, index) {
                    final mov = controller.historico[index];
                    final isEntrada = mov.tipo == 'ENTRADA';

                    return ListTile(
                      leading: Icon(
                        isEntrada ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isEntrada ? Colors.green : Colors.red,
                      ),
                      title: Text('${mov.tipo} de ${mov.quantidade} unidades'),
                      subtitle: Text(
                        'Data: ${DateTime.parse(mov.data).toLocal().toString().split('.')[0]}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
