import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigPage extends StatefulWidget {
  //atributos
  final bool temaEscuro; // atributo para armazenar o tema escuro
  final String nomeUsuario; // atributo para armazenar o nome do usuário
  final Function(bool,String) onSalvar; // atributo para armazenar a função de salvar as configurações

  //construtor
  const ConfigPage({super.key, required this.temaEscuro, required this.nomeUsuario, required this.onSalvar});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
//atributos
  late bool _temaEscuro; // atributo para armazenar o tema escuro : late => inicializa a variavel e depois muda o valor
  late TextEditingController _nomeUsuario; // atributo para armazenar o nome do usuário : late => inicializa a variavel e depois muda o valor

  //método para iniciar as variáveis
  @override
  initState(){
    super.initState();
    _temaEscuro = widget.temaEscuro; //atribui o valor do tema escuro passado pelo construtor para a variável local
    _nomeUsuario = TextEditingController(text: widget.nomeUsuario); // mesma coisa para nome do usuário
  }

  //método para salvar as configuraçoes  do usuário
  void salvarConfig() async {
    Map<String, dynamic> config = {
      "temaEscuro": _temaEscuro,
      "nome": _nomeUsuario.text.trim()
    };
    //chamar o SharedPreferences 
    //converter o MAP => String/Json
    //Salvar o Valor no SharedPreferences para a Chave "config"
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(config);
    prefs.setString("config", jsonString);

    //chamar a Atualização 
    widget.onSalvar(_temaEscuro,_nomeUsuario.text.trim());

  }

  //build da Tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preferências do Usuário"),),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            //botão apra mudar o tema escuro
            SwitchListTile(
              title: Text("Tema Escuro"),
              value: _temaEscuro,
              onChanged: (bool value){
                setState(() {
                  _temaEscuro = value;
                });
              },),
            TextField(
              controller: _nomeUsuario,
              decoration: InputDecoration(
                labelText: "Nome do Usuário"
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async{
                salvarConfig();
                // ScaffoldMessenger
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Preferências Salvas")));
              }, child: Text("Salvar Preferências")),
              Divider(),
              Text("Resumo Atual:", style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text("Tema: ${_temaEscuro? "Escuro" : "Claro"}"),
              Text("Usuário: ${_nomeUsuario.text}")
          ],
        ),),
    );
  }
}