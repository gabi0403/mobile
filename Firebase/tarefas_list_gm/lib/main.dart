import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tarefas_list_gm/firebase_options.dart';
import 'package:tarefas_list_gm/screen/auth_screen.dart';

void main(List<String> args) async{
  //Garantir o carregamento widgets do flutter
  WidgetsFlutterBinding.ensureInitialized();
  //Inicializar o carregamento do fireBase
  await Firebase.initializeApp(
    //garante o carregamento do firebase na plataforma android
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MaterialApp(home: AuthScreen(),));
}