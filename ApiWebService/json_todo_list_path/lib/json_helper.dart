import "dart:io";
import "dart:convert";
import "package:path_provider/path_provider.dart";

class JsonHelper {
  // método obter o arquivo json do path
  // static => método da classe e não do Objeto -> permite rodar o método sem instanciar um OBJ
  static Future<File> _getArquivo() async {
    final diretorio =
        await getApplicationDocumentsDirectory(); //pega o diretório do app
    return File("${diretorio.path}/config.json"); //retorna o arquivo json
  }

  // método para salvar os dados no arquivo json
  static Future<Map<String, dynamic>> lerDados() async {
    try {
      //pega o arquivo json
      final arquivo = await _getArquivo();
      // verifico se ele existe
      if (await arquivo.exists()) {
        //leio o conteúdo do arquivo
        final conteudo = await arquivo.readAsString();
        //converto o conteúdo do arquivo em Map
        return json.decode(conteudo);
      }
    } catch (e) {
      print("Erro ao ler dados: $e");
    }
    return {};
  }

  // metodo para salavar os dados no arquivo json
  static Future<void> salvarDados(Map<String, dynamic> dados) async {
    try {
      //pega o arquivo json
      final arquivo = await _getArquivo();
      //converto o Map em String
      final conteudo = json.encode(dados);
      //salvo o conteúdo no arquivo
      await arquivo.writeAsString(conteudo);
    } catch (e) {
      print("Erro ao salvar dados: $e");
    }
  }
}
