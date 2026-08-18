import 'package:biblioteca_app_json/controller/user_controller.dart';
import 'package:biblioteca_app_json/model/user_model.dart';
import 'package:biblioteca_app_json/view/user_form_page.dart';
import 'package:flutter/material.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  //atributos
  List<UserModel> _users = [];
  //permitir o filtro de usuários
  final _userSearch = TextEditingController(); // campo para digitar o nome do usuário
  List<UserModel> _filterUsers = [];
  bool _isLoading = true;
  // ignore: unused_field
  String _error = "";

  final _userController = UserController(); 


  //métodos 

  @override
  void initState() {//sempre que preciso carregar informações antes do build da page , usar o método initState
    super.initState();
    _load();//Carregar as informações da API
  }

  //carregar info da API
  void _load() async{
    setState(() {
      _isLoading = true;
    });
    try {
      _users = await _userController.fetchAll();
      _filterUsers = _users;
    } catch (e) {
      //Tratar o erro
      _error = e.toString();
    }
    setState(() {
      _isLoading = false;
    });
  }

  //método para filtragem do lista de usuários
  void _usersFilter(){
    final query = _userSearch.text.toLowerCase();
    setState(() {
      //fazendo um filtro por partes do nome ou parte do email
      _filterUsers = _users.where((user){
        return user.name.toLowerCase().contains(query) || user.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  //método de Navegação para a pág de cadastro de usuário
  void _openForm ({UserModel? user}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context)=> UserFormPage(user:user)));
    //quando eu voltar para a págian de listagem de usuário , recarrega a lista de usuários
    _load();
  }

  void _delete(UserModel user) async{
    final confirm = await showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text("Confirma Exclusão"),
        content: Text("Deseja realmente exluir o usuário ${user.name}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context,false), child: Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context,true), child: Text("Excluir"))
        ],
      ));
      if(confirm){
        try {
          await _userController.delete(user.id!);
        } catch (e) {
          //criar uma mensagem de Erro
        }
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // não precisa de appbar pois ja esta no home
      body: _isLoading 
      ? Center(child: CircularProgressIndicator(),)
      : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _userSearch,
              decoration: InputDecoration(
                labelText:  "Pesquisar Usuário",
                border: OutlineInputBorder()
              ),
              onChanged: (value) => _usersFilter(),
            ),
            SizedBox(height: 16,),
            Expanded(child: ListView.builder(
              itemCount: _filterUsers.length,
              itemBuilder: (context,index){
                final user = _filterUsers[index];
                return Card(
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: ()=> _openForm(user:user), icon: Icon(Icons.edit)),
                        IconButton(onPressed: () => _delete(user), icon: Icon(Icons.delete, color: Colors.red),)
                      ],
                    ),
                  ),
                );
              }))
          ],
        ) ,),
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), child: Icon(Icons.add),),
    );
  }
}