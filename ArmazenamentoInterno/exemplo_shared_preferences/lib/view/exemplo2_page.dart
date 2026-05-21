import 'package:exemplo_shared_preferences/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Exemplo2Page extends StatefulWidget {
  const Exemplo2Page({super.key});

  @override
  State<Exemplo2Page> createState() => _Exemplo2PageState();
}

class _Exemplo2PageState extends State<Exemplo2Page> {
  late SharedPreferences _prefs; //escopo late permite criar uma variável obj inicialmente nula e mudar o valor depois, pode ser mudada quantas vezes for necessário
  bool _darkMode = false;
  
  //métodos de conexão com o sharedpreferences 
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  //método pra buscar dados no Shared
  void _loadPreferences() async{
    _prefs = await
  SharedPreferences.getInstance(); //pega as informações salvas no shared
  setState(() {
    _darkMode = _prefs.getBool("darkMode") ?? false; //verificação de nulidade obrigatória, ?? se caso a chave darkMode no Shared seja nula a variável _darkMode será false
  });
  
  }

  //método pra salvar dados no Shared
   void savePreferences() async {
    setState(() {
      _darkMode = !_darkMode; // Muda o valor da booleana
    });
    await _prefs.setBool("darkMode", _darkMode);
 
    themeNotifier.value = _darkMode ? ThemeMode.dark : ThemeMode.light;
    // Atribuindo o valor da variavel _darkMode a chave darkMode do Shared
  }

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modo Escuro com Shared Preferences"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Tema Atual: ${_darkMode ? "Escuro" : "Claro"}"),
            Switch(
              value: _darkMode, 
              onChanged: (_)=>savePreferences()), //Switch
          ],
        ),
      )
    );
  }
}