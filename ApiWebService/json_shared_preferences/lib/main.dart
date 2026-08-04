import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config_page.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  //atributos
  bool temaEscuro = false;
  String nomeUsuario = "";

  //método para carregar informações antes memos do build da tela
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    carregarPreferencias();
  }

  //método para conectar com o shared preferences
  void carregarPreferencias() async{ //async => não trava a aplicação se caso a busca der errado
    //conexão com o sharedPreferences ( pub add para adicionar o sharedPreferences na aplicação)
    final prefs = await SharedPreferences.getInstance(); //conecta com o cache para pegar informações do usuário
    //armazena em um texto as configurações salvas pelo usuário da aplicação
    String? jsonString = prefs.getString("config"); // ? => variavel permite ser nula
    //se jsonString não for nula 
    if(jsonString != null){
      //converter o texto/Json em Map/Dart
      Map<String, dynamic> config = json.decode(jsonString);
      //chama a mudança de estado
      setState(() {
        //atribuir as variaveis os valores armazenados
        temaEscuro = config["temaEscuro"] ?? false; // se a variavel temaescuro for nula  atribua o valor false
        nomeUsuario = config["nome"] ?? ""; // se variavel nome = null => ""
      });
    }
  }


  //método build
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App de Configuração",
      theme: temaEscuro ? ThemeData.dark() : ThemeData.light(),
      home: ConfigPage(
        temaEscuro: temaEscuro,
        nomeUsuario: nomeUsuario,
        onSalvar: (bool tema, String nome){
          setState(() {
            temaEscuro = tema;
            nomeUsuario = nome;
          });
        },
      ),
    );
  }
}