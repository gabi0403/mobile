// criar o void main
// responsável por rodar o elemento principal da aplicação 

import 'package:flutter/material.dart';

void main(){
  //runApp => chama o elemetno com o materialAPP
  runApp(MainApp());
}

//criar a classe MainApp
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  //Construtor da Tela Estática
  @override
  Widget build(BuildContext context) {
    //montar a estrutura do MaterialAPP
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Tela de Login"),),
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children://permite mais de 1 abre colchetes 
            [
              //elementos de input de texto
              Text("Email"),
              TextField(textAlign: TextAlign.center,),
              Text("Senha"),
              TextField(textAlign: TextAlign.center,obscureText: true,),
              TextButton(onPressed: (){}, child: Text("Enviar"))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items://permite mais de 1, abre colchetes
          [
            BottomNavigationBarItem(icon: Icon(Icons.arrow_back),label: "back"),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.arrow_forward),label: "forward"),
            
          ]
         ),
      ),
    );
  }
}