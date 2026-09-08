// aplicação de uso do gps com api de clima

import 'package:exemplo_geolocator_clima/api_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String mensagem = "teste";
  String clima = "teste";
  late Position position; 

  final ApiService apiService = ApiService();

  // método para buscar a localização
  void getLocation() async{
    bool enable;
    LocationPermission permission;

    //verificar se o serviço de localização esta habilitado
    enable = await Geolocator. isLocationServiceEnabled();
    // Se a permissão não estiver habilitada
    if(!enable){
      mensagem = "Serviço de Localização desabilitado";
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission(); // vou solicitar a permissão
      if(permission == LocationPermission.denied){
        mensagem = "Acesso a Localização não Permitido pelo Usuário";
      }
    //permissão liberada=
    }    
    //pegando a posição atual
    position = await Geolocator.getCurrentPosition();
    mensagem = "Latitude ${position.latitude}, Longitude: ${position.longitude}";
  }

  //método para buscar o clima na api a partir da localização
  void getClima() async{
    getLocation();

    try {
      final climaAtual = await apiService.getClimaLocation(position);
      if (climaAtual != null){
        clima = "${climaAtual["name"]} -- ${climaAtual["main"]["temp"] - 273}°";
      }
    } catch (e) {
      clima = e.toString();
    }
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getLocation();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clima e GPS"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mensagem),
            ElevatedButton(onPressed: () async{
              getClima();
            }, 
            child: Text("Buscar Clima")),
            Text(clima)
          ],
        ),
      ),
    );
  }
}