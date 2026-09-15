import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main(List<String> args) {
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startScan();
  }

  void _startScan() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dispositivos BlueTooth"),
        actions: [
          IconButton(onPressed: _startScan, icon: Icon(Icons.refresh))
        ],),
      body: StreamBuilder<bool>(
        // 1º Stream Vericar o Busca do BlueTooth
        stream: FlutterBluePlus.isScanning,
        initialData: false,  
        builder: (context, snapshotScanning){
          final isScanning = snapshotScanning.data ?? false;// verificador de nulidade(Coalescência Nula)
          //2º Stream: Monitorar o dispositivos
          return StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            initialData: [], //armazenar os dispositivos bluetooth
            builder: (context, snapshotResults){
              final dispositivos = snapshotResults.data ?? [];
              if(isScanning && dispositivos.isEmpty){
                return Center(child: CircularProgressIndicator(),);
              } else if(dispositivos.isEmpty){
                return Center(child: Text("Lista Vazia"),);
              } else{
                return ListView.builder(
                  itemCount: dispositivos.length,
                  itemBuilder: (context,index){
                    final item = dispositivos[index];
                    final name = item.device.platformName.isNotEmpty ? item.device.platformName : "Dispositivo Sem Nome";
                    return ListTile(
                      title: Text(name),
                      subtitle: Text(item.device.remoteId.str),
                      trailing: Text("${item.rssi} dBm"),
                    );
                  });
              }
            });
        }),
    );
  }
}