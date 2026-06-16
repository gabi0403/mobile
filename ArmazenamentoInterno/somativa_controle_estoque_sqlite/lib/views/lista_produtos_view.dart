import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/produto_controller.dart';
import '../controllers/theme_controller.dart';
import 'cadastro_produto_view.dart';
import 'detalhes_produto_view.dart';

class ListaProdutosView extends StatefulWidget {
  const ListaProdutosView({super.key});

  @override
  State<ListaProdutosView> createState() => _ListaProdutosViewState();
}

class _ListaProdutosViewState extends State<ListaProdutosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProdutoController>().carregarProdutos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final isDarkMode = themeController.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque Atual'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Modo claro' : 'Modo escuro',
            onPressed: () => themeController.toggleTheme(),
          ),
        ],
      ),
      body: Consumer<ProdutoController>(
        builder: (context, controller, child) {
          if (controller.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.erro.isNotEmpty) {
            return Center(
              child: Text(
                controller.erro,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          if (controller.produtos.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado.'));
          }

          return Column(
            children: [
              // Mensagem informativa
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.blue.shade400.withOpacity(0.2),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Arraste um produto para a esquerda para excluir',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.produtos.length,
                  itemBuilder: (context, index) {
                    final produto = controller.produtos[index];
                    return Dismissible(
                      key: ValueKey(produto.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red.shade700,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Excluir produto'),
                              content: Text(
                                'Deseja remover "${produto.nome}" do estoque?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Excluir'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (_) async {
                        final sucesso = await controller.excluirProduto(
                          produto.id!,
                        );
                        if (!sucesso && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(controller.erro),
                              backgroundColor: Colors.red.shade600,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Produto "${produto.nome}" removido com sucesso.',
                              ),
                              backgroundColor: Colors.green.shade600,
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            produto.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Código: ${produto.codigo}'),
                          trailing: CircleAvatar(
                            backgroundColor: produto.quantidadeAtual > 0
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            child: Text(
                              '${produto.quantidadeAtual}',
                              style: TextStyle(
                                color: produto.quantidadeAtual > 0
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetalhesProdutoView(produto: produto),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CadastroProdutoView()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
