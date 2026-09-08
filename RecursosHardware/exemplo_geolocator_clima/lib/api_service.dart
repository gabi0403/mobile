//permitir a conexão com a API de clima
//chave da api 90290436d34bb91b4d852afe49197129

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String baseUrl = "https://api.openweathermap.org/data/2.5/weather";
  String chaveApi = "90290436d34bb91b4d852afe49197129";

  Future<Map<String,dynamic>?> getClimaLocation(Position position) async{
    //endereço URL da consulta da API
    // a URL + Request Parans
    final response = await http.get(Uri.parse("$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$chaveApi"));
    //verificação da resposta
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }else{
      throw Exception("Falha de Conexão");
    }
  } 
}

