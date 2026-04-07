import 'package:flutter/material.dart';

import 'pages/formulario_page.dart';
import 'pages/home_page.dart';
import 'pages/contato_page.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    //sistema de rotas para navegação entre telas
    //home: -> tela inicial
    //form: -> tela de formulário
    //contato: -> tela de contato
    routes:
      {
        "/": (context) => HomePage(),
        "/form": (context) => FormularioPage(),
        "/contato": (context) => ContatoPage(),
      } 
    ,
    initialRoute: "/", //direciona o aplicativo para a homepage ao abrir

  ));
}