import 'dart:convert'; //biblioteca nativa json

import 'package:http/http.dart' as http; //importar biblioteca http

class ApiService {
  static const String baseUrl = "http://localhost:3000"; //URL base API

  // métodos de classe para acessar os endpoints da api
  //GET(All)
  static Future<List<dynamic>> getList(String path) async {
    final res = await http.get(
      Uri.parse("$baseUrl/$path"),
    ); // no dart precisa converter String em Endereço URL (URI.parse)
    if (res.statusCode == 200)
      return json.decode(
        res.body,
      ); // se reposta OK -> conver json em MAP<dynamic>
    //se deu ruim => a conexão gera um erro
    // vou gerar um erro
    throw Exception("Falha de conexão com $path");
  }

  //GET(one)
  static Future<Map<String, dynamic>> getOne(String path, String id) async {
    final res = await http.get(Uri.parse("$baseUrl/$path/$id"));
    if (res.statusCode == 200) return json.decode(res.body);
    //se der errado
    throw Exception("Falha de conexão com $path");
  }

  //POST
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/$path"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    //se der errado
    throw Exception("Falha de conexão com $path");
  }

  //PUT
  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
    String id,
  ) async {
    final res = await http.put(
      Uri.parse("$baseUrl/$path/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    //se der errado
    throw Exception("Falha de conexão com $path");
  }

  //DELETE
  static delete(String path, String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/$id"));
    if (res.statusCode != 200) throw Exception("Falha ao Deletar de $path");
  }
}
