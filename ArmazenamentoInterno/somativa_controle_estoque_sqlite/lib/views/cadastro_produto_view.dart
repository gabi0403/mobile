import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/produto_controller.dart';
import '../models/produto_model.dart';

class CadastroProdutoView extends StatefulWidget {
  const CadastroProdutoView({super.key});

  @override
  State<CadastroProdutoView> createState() => _CadastroProdutoViewState();
}

class _CadastroProdutoViewState extends State<CadastroProdutoView> {
  final _chaveFormulario = GlobalKey<FormState>();
  
  // Controladores dos campos de texto
  final _nomeCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoCustoCtrl = TextEditingController();
  final _precoVendaCtrl = TextEditingController();
  final _quantidadeCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();

  void _salvar() async {
    if (_chaveFormulario.currentState!.validate()) {
      final produto = ProdutoModel(
        nome: _nomeCtrl.text,
        descricao: _descricaoCtrl.text,
        precoCusto: double.parse(_precoCustoCtrl.text),
        precoVenda: double.parse(_precoVendaCtrl.text),
        quantidadeAtual: int.parse(_quantidadeCtrl.text),
        codigo: _codigoCtrl.text,
      );

      final sucesso = await context.read<ProdutoController>().salvarProduto(produto);

      if (sucesso) {
        if (mounted) Navigator.pop(context); // Volta para a tela anterior
      } else {
        if (mounted) {
          final erro = context.read<ProdutoController>().erro;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _chaveFormulario,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                validator: (valor) => valor!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(labelText: 'Código (SKU/Barras)'),
                validator: (valor) => valor!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoCtrl,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoCustoCtrl,
                      decoration: const InputDecoration(labelText: 'Preço de Custo'),
                      keyboardType: TextInputType.number,
                      validator: (valor) => valor!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _precoVendaCtrl,
                      decoration: const InputDecoration(labelText: 'Preço de Venda'),
                      keyboardType: TextInputType.number,
                      validator: (valor) => valor!.isEmpty ? 'Obrigatório' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _quantidadeCtrl,
                decoration: const InputDecoration(labelText: 'Quantidade Inicial'),
                keyboardType: TextInputType.number,
                validator: (valor) => valor!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Salvar Produto', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}