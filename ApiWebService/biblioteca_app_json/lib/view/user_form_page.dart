import 'package:biblioteca_app_json/controller/user_controller.dart';
import 'package:biblioteca_app_json/model/user_model.dart';
import 'package:flutter/material.dart';

class UserFormPage extends StatefulWidget {
  //atributo
  final UserModel? user; //pode ser nulo
  const UserFormPage({super.key, this.user});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  //ATRIBUTOS
  final _formkey =
      GlobalKey<FormState>(); //aramazenas as informações do formulário
  final _userController = UserController();
  final _nameInput = TextEditingController();
  final _emailInput = TextEditingController();
  String idUser = "";

  // se exisitr dados do usuário precisa do initState
  @override
  void initState() {
    super.initState();
    // pegar os dados se for edição
    if (widget.user != null) {
      idUser = widget.user!.id!;
      _nameInput.text = widget.user!.name;
      _emailInput.text = widget.user!.email;
    }
  }

  //metodos
  void save() async {
    if (_formkey.currentState!.validate()) {
      final user = UserModel(
        name: _nameInput.text.trim(),
        email: _emailInput.text.trim(),
      );
      try {
        await _userController.create(user);
      } catch (e) {
        //tratar o erro
      }
      Navigator.pop(context);
      // se não der certo fazer um navigator PushName
    }
  }

  void update() async {
    if (_formkey.currentState!.validate()) {
      final user = UserModel(
        id: widget.user!.id!,
        name: _nameInput.text.trim(),
        email: _emailInput.text.trim(),
      );
      try {
        await _userController.update(user);
      } catch (e) {
        //tratar erro
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user == null ? "Novo usuário" : "Editar usuário ${widget.user!.name}"),),
      body: Padding(padding: EdgeInsets.all(16),
      child: Form(
        key: _formkey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameInput ,
              decoration: InputDecoration(labelText: "Nome"),
              validator: (value) => value!.isEmpty ? "Informe o nome" : null,
            ),
            TextFormField(
              controller: _emailInput ,
              decoration: InputDecoration(labelText: "Email"),
              validator: (value) => value!.isEmpty ? "Informe o email" : null,
            ),
            SizedBox(height: 16,),
            ElevatedButton(
              onPressed: widget.user ==null ? save : update,
              child: Text(widget.user ==null ? "Salvar" : "Atualizar"))
          ],
        )),),
    );
  }
}