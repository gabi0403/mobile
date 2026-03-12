import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Perfil',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const PerfilPage(),
    );
  }
}

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  Widget infoCard(String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 5),
          Text(value),
        ],
      ),
    );
  }

  Widget socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: Icon(icon, size: 30),
    );
  }

  Widget profileInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Habilidades"),
          SizedBox(height: 10),
          Text("Formação"),
          SizedBox(height: 10),
          Text("Empresa"),
          SizedBox(height: 10),
          Text("Localização"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.share),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            const SizedBox(height: 20),

            // foto
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
            ),

            const SizedBox(height: 15),

            // nome
            const Text(
              "Nome",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text("Biografia/descrição"),

            const SizedBox(height: 20),

            // cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                infoCard("Projetos", "0"),
                infoCard("Conexões", "0"),
                infoCard("Seguidores", "0"),
              ],
            ),

            const SizedBox(height: 20),

            // redes sociais
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                socialIcon(Icons.business),
                socialIcon(Icons.code),
                socialIcon(Icons.alternate_email),
              ],
            ),

            const SizedBox(height: 20),

            // informações
            profileInfo(),
          ],
        ),
      ),

      // navBar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Config"),
        ],
      ),
    );
  }
}
