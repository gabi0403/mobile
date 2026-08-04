import 'package:flutter/material.dart';
import 'package:json_todo_list_path/json_helper.dart';
import 'package:json_todo_list_path/tarefas_page.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  Map<String, dynamic> _baseDados = {};
  final TextEditingController _nomeController = TextEditingController();

  initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final dados = await JsonHelper.lerDados();
    setState(() {
      _baseDados = dados;
      _nomeController.text = _baseDados['nome'] ?? '';
    });
  }

  void _adicionarUsuario() async {
    final nome = _nomeController.text;
    if (nome.isNotEmpty) {
      _baseDados['nome'] = nome;
      await JsonHelper.salvarDados(_baseDados);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário adicionado com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> usuarios = _baseDados.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuários'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Usuário'),
            ),
          ),
          ElevatedButton(
            onPressed: _adicionarUsuario,
            child: const Text('Adicionar Usuário'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                return ListTile(
                  title: Text(usuario),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      setState(() {
                        _baseDados.remove(usuario);
                      });
                      await JsonHelper.salvarDados(_baseDados);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuário removido com sucesso!')),
                      );
                    },
                  ),
                  onTap:() {
                    //Navega para as tarefas do usuario selecionado
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TarefasPage(nomeUsuario: usuario, banco: _baseDados),
                      ),
                    ).then((value) => _carregarDados()); // Atualiza a lista de usuários ao voltar da página de tarefas
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