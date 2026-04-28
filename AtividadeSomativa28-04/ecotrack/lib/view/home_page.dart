import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/habito_controller.dart';

// 1. tela incial
class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 100, color: Colors.green),
              const Text("EcoTrack", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // breve descrição da proposta
              const Text(
                "Acompanhe seus hábitos sustentáveis e veja seu impacto positivo no planeta!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage())),
                child: const Text("Começar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Tela principal (navegação)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _abaAtual = 0; // Controla o BottomNavigationBar

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HabitoController>(context);

    // Lista de telas
    final List<Widget> _telas = [
      _construirDashboard(controller),
      _construirListaHabitos(controller),
      _construirConfiguracoes(controller),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoTrack"),
        actions: [
          // Indicador de progresso na AppBar
          Center(child: Text("${(controller.progressoMeta * 100).toInt()}% ")),
          const Icon(Icons.notifications),
          const SizedBox(width: 10),
        ],
      ),
      // Drawer (Menu Lateral)
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Center(child: Text("Menu Ambiental", style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            ListTile(leading: const Icon(Icons.analytics), title: const Text("Dashboard"), onTap: () { Navigator.pop(context); setState(() => _abaAtual = 0); }),
            ListTile(leading: const Icon(Icons.eco), title: const Text("Hábitos"), onTap: () { Navigator.pop(context); setState(() => _abaAtual = 1); }),
            ListTile(leading: const Icon(Icons.settings), title: const Text("Configurações"), onTap: () { Navigator.pop(context); setState(() => _abaAtual = 2); }),
          ],
        ),
      ),
      body: _telas[_abaAtual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        onTap: (i) => setState(() => _abaAtual = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dash"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Hábitos"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Config"),
        ],
      ),
    );
  }

  // Dashboard
  Widget _construirDashboard(HabitoController controller) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _cardDash("Concluídos", controller.totalConcluidos.toString(), Colors.green),
        _cardDash("Pontuação", "${controller.pontuacaoTotal} pts", Colors.blue),
        _cardDash("Nível Atual", controller.nivelUsuario, Colors.orange),
        _cardDash("Impacto (CO2)", controller.impactoEstimado, Colors.teal),
      ],
    );
  }

  // Lista de habitos
  Widget _construirListaHabitos(HabitoController controller) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: "Pendentes"), Tab(text: "Concluídos")]),
          Expanded(
            child: TabBarView(
              children: [
                _gerarLista(controller.habitosPendentes, true, controller),
                _gerarLista(controller.habitosConcluidos, false, controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gerarLista(List habitos, bool pendente, HabitoController controller) {
    return ListView.builder(
      itemCount: habitos.length,
      itemBuilder: (context, i) {
        final h = habitos[i];
        return Card(
          child: ListTile(
            title: Text(h.titulo),
            trailing: pendente 
              ? IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: () => controller.concluirHabito(h))
              : const Icon(Icons.check, color: Colors.green),
          ),
        );
      },
    );
  }

  // Configurações
  Widget _construirConfiguracoes(HabitoController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Ativar/Desativar modo escuro
          SwitchListTile(
            title: const Text("Modo Escuro"),
            value: controller.modoEscuro,
            onChanged: (v) => controller.alternarTema(),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () => controller.reiniciarProgresso(),
            child: const Text("Limpar Hábitos Concluídos"),
          ),
        ],
      ),
    );
  }

  Widget _cardDash(String tit, String val, Color cor) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(tit, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(val, style: TextStyle(fontSize: 22, color: cor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}