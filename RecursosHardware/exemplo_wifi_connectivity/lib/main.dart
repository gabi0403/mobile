import 'dart:async'; //biblioteca para usar o Stream
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //criar um mensagem
  String _mensagem = "Verificando...";

  //Objeto para "ouvir" as mudanças de Conexão wifi
  late StreamSubscription<List<ConnectivityResult>> _wifiObserver;
  
  //métodos
  @override
  void initState() {
    super.initState();
    //1. Check do wifi
    _checkInitialConnection();
    //2. Começar a ouvir as mudanças de conexão em tempo real.
    _wifiObserver = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results){
      //Pega o primeiro resultado disponivel , ou ConnectivityResult.none se a lista estiver vazia
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _updateConnectionStatus(result);
    });
  }

  void _checkInitialConnection() async{
    //var recebe o valor das mudanças
    var _connectivityResult = (await Connectivity().checkConnectivity()) as ConnectivityResult;
    _updateConnectionStatus(_connectivityResult);
  }

  //método para identificar mudanças de conexão wifi
  void _updateConnectionStatus(ConnectivityResult result){
    setState(() {
      switch (result) {
        case ConnectivityResult.wifi:
          _mensagem = "Conectado no WIFI";
          break;
        case ConnectivityResult.mobile:
          _mensagem = "Conectado via Dados Móveis";
          break;
        case ConnectivityResult.none:
          _mensagem = "Sem Conexão com a Internet";
          break;
        default:
        _mensagem = "Procurando Conexão...";
        break;
      }
    });
  }
  //limpar a memória ao sair da Tela
  @override
  void dispose() {
    super.dispose();
    _wifiObserver.cancel();
                                                                      
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Status da Conexão"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              //icone vai mudar de acordo com a conexão
              _mensagem.contains("WIFI") ? Icons.wifi :
              _mensagem.contains("Dados") ? Icons.network_cell :
              Icons.wifi_off,
              size: 80,
              color: _mensagem.contains("Sem") ? Colors.red : Colors.green,
            ),
            SizedBox(height: 10,),
            Text("Status: $_mensagem")
          ],
        ),
      ),

    );
  }
}