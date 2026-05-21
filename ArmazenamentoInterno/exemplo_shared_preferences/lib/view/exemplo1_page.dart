// uso do shared preferences pra armazenar o nome do usuário

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Exemplo1Page extends StatefulWidget {
  const Exemplo1Page({super.key});

  @override
  State<Exemplo1Page> createState() => _Exemplo1PageState();
}

class _Exemplo1PageState extends State<Exemplo1Page> {
  TextEditingController _nomeInput = TextEditingController();
  String _nomeSalvo = "";

  //uso shared para buscar o nome no inicio do aplicativo 
  //salvar nome nas preferencias
  _salvarNomeShared() async{ // conexão async -> permite continuar rodadno o código enquanto é feito a conexão com a base de dados
  //conectar com o SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance(); //busca as informações salvas no shared prefs
  await prefs.setString("nome",_nomeInput.text.trim()); // salvou na chave "nome" -> o valor colocado no input
  _nomeInput.clear(); //limpa o input

  }

  //buscar nome nas preferencias
  _carregarNomeShared() async{
    SharedPreferences prefs = await SharedPreferences.getInstance(); // atualiza o estado da página
    setState(() {
      // atribuindo a variável o valo relacionada a chave buscada no shared
      _nomeSalvo = prefs.getString("nome") ?? ""; //operador de nulidade
    });
  }

  //inicio da página
  @override
  // método que é iniciado antes mesmo do build da tela
  void initState() {//carrega informações do sharedPreferences antes de buildar a tela pela primeira vez
    super.initState(); 
    _carregarNomeShared();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bem Vindo $_nomeSalvo"), centerTitle: true,),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _nomeInput,
              decoration: InputDecoration(labelText: "Digite seu nome..."),
            ),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: _salvarNomeShared, child: Text("Salvar")),
            SizedBox(),
            Text("O Nome do Usuário Atual é $_nomeSalvo", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20,),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Voltar"))
          ],
        ),),
    );
  }
}