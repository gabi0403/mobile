// tela para estudo dos widgets de exibição
//  text, image, icon entre outros

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      //configurações iniciais do App
      //router => rotas de navegação
      //home => pagina Inicial
      home: MyApp(),
      //themeApp => (Claro/Escuro)
    ),
  ); //gosto de colocar o MaterialApp no void main
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // estrutura da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //elemento principal da tela
      //appbar, drawer, bnBar, body, fabutton, snakebar
      appBar: AppBar(title: Text("Exemplos de Widget de Exibição")),

      //add um elemento de Scroll

      body: SingleChildScrollView(
        //+ usado para scroll de Tela Inteira
        child: Padding(
          padding: EdgeInsets.all(16),
          //Widget de Text
          //add um container
        
          child: Expanded(
            //+ usado para Scroll de Parte da Tela
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Explorando o Flutter",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                //dentro da column
                //add uma image
                Image.network(
                  //link url da Imagem
                  "https://plus.unsplash.com/premium_photo-1677545183884-421157b2da02",
                  height: 400,
                  fit: BoxFit.contain,),
                  // add imagem local
                  Image.asset("assets/img/pinguim.png",
                    height: 250,
                    fit: BoxFit.cover,)
                    
              ],
            ),
          ),
        ),
      ),

    );
  }
}



