// tela inicial 
// vai ter botões de navegação para outras telas

import 'package:flutter/material.dart';

//Tela inicial -> Logo do Aplicativo e Botões de Navegação
// Logo com SplashScreen -> Tela de Carregamento
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meu Aplciativo Interativo"),),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            //alinhamento do eixo principal(vertical)
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo do aplicativo com atraso de carregamento de 2 segundos
              Image.network("https://thumbs.dreamstime.com/b/logotipo-cl%C3%A1ssico-do-batman-isolado-em-fundo-branco-dia-bolonha-it%C3%A1lia-de-setembro-404052715.jpg",
              width: 150,
              height: 150,),
              //bloco de espaçamento entre objetos
              SizedBox(height: 20,),
              //botões de navegação
              ElevatedButton(
                //método de navegação para a tela de formualário
                onPressed: ()=> Navigator.pushNamed(context, "/form"),
                //texto do botão
                child: Text("Formulário")),
              SizedBox(height: 10,),
              ElevatedButton(
                //método de navegação para a tela de formualário
                onPressed: ()=> Navigator.pushNamed(context, "/contato"),
                //texto do botão
                child: Text("Contato")),
            ],
          ),
        ),),
    );
  }
}