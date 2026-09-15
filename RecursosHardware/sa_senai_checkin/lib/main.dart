import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(const App());

class Record {
  Record({
    this.id,
    required this.date,
    required this.lat,
    required this.lng,
    required this.note,
    required this.photo,
  });
  int? id;
  DateTime date;
  double lat, lng;
  String note;
  String? photo;

  Map<String, Object?> toMap() => {
    'id': id,
    'date_hora': date.toIso8601String(),
    'latitude': lat,
    'longitude': lng,
    'observacao': note,
    'caminho_foto': photo,
  };

  factory Record.fromMap(Map<String, Object?> map) => Record(
    id: map['id'] as int?,
    date: DateTime.parse(map['date_hora'] as String),
    lat: (map['latitude'] as num).toDouble(),
    lng: (map['longitude'] as num).toDouble(),
    note: map['observacao'] as String,
    photo: map['caminho_foto'] as String?,
  );
}

class DatabaseHelper {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      '${await getDatabasesPath()}/registros.db',
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE registros (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date_hora TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          observacao TEXT NOT NULL,
          caminho_foto TEXT
        )
      '''),
    );
    return _db!;
  }

  Future<List<Record>> all() async {
    final rows = await (await db).query('registros', orderBy: 'date_hora DESC');
    return rows.map(Record.fromMap).toList();
  }

  Future<void> save(Record record) async =>
      (await db).insert('registros', record.toMap());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'SA SENAI Check-in',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      scaffoldBackgroundColor: const Color(0xfff4f7f7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff123b4a),
        foregroundColor: Colors.white,
      ),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final database = DatabaseHelper();
  List<Record> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await database.all();
    if (mounted) {
      setState(() {
        records = result;
        loading = false;
      });
    }
  }

  Future<void> newRecord() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NewPage(database)),
    );
    if (saved == true) {
      await load();
      await SystemSound.play(SystemSoundType.click);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro salvo com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SA SENAI - Registros de campo')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: newRecord,
      icon: const Icon(Icons.add),
      label: const Text('Novo registro'),
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : records.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nenhum registro salvo.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: newRecord,
                  child: const Text('Registrar visita'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            itemBuilder: (_, index) {
              final record = records[index];
              final image = record.photo == null ? null : File(record.photo!);
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: SizedBox(
                    width: 64,
                    height: 64,
                    child: image == null
                        ? const Icon(Icons.photo, size: 42)
                        : Image.file(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image),
                          ),
                  ),
                  title: Text(
                    formatDate(record.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${record.lat.toStringAsFixed(5)}, ${record.lng.toStringAsFixed(5)}\n${record.note}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailsPage(record)),
                  ),
                ),
              );
            },
          ),
  );
}

class NewPage extends StatefulWidget {
  const NewPage(this.database, {super.key});
  final DatabaseHelper database;
  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  final note = TextEditingController();
  final picker = ImagePicker();
  XFile? photo;
  Position? position;
  bool busy = false;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  Future<bool> permissions() async {
    final result = await [Permission.camera, Permission.location].request();
    if (result[Permission.camera] != PermissionStatus.granted ||
        result[Permission.location] != PermissionStatus.granted) {
      message('Permissão de câmera e localização é necessária.');
      return false;
    }
    return true;
  }

  Future<void> takePhoto() async {
    if (!await permissions()) return;
    final result = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (result != null) {
      setState(() => photo = result);
    }
  }

  Future<void> getLocation() async {
    if (!await permissions()) return;
    setState(() => busy = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Ative o GPS do celular.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Localização negada.');
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {});
    } catch (error) {
      message(error.toString().replaceFirst('Exception: ', ''));
    }
    setState(() => busy = false);
  }

  Future<void> save() async {
    if (photo == null || position == null) {
      message('Tire a foto e obtenha a localização antes de salvar.');
      return;
    }
    setState(() => busy = true);
    final folder = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/imagens',
    );
    await folder.create(recursive: true);
    final file = await File(photo!.path).copy(
      '${folder.path}/registro_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await widget.database.save(
      Record(
        date: DateTime.now(),
        lat: position!.latitude,
        lng: position!.longitude,
        note: note.text.trim(),
        photo: file.path,
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  void message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Novo registro')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Dados da visita',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: busy ? null : takePhoto,
          icon: const Icon(Icons.camera_alt),
          label: Text(photo == null ? 'Tirar foto do local' : 'Foto capturada'),
        ),
        if (photo != null) ...[
          const SizedBox(height: 12),
          Image.file(File(photo!.path), height: 180, fit: BoxFit.cover),
        ],
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: busy ? null : getLocation,
          icon: const Icon(Icons.location_on),
          label: Text(
            position == null
                ? 'Obter localização GPS'
                : '${position!.latitude}, ${position!.longitude}',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: note,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observação',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: busy ? null : save,
          icon: const Icon(Icons.save),
          label: const Text('Salvar registro'),
        ),
      ],
    ),
  );
}

class DetailsPage extends StatelessWidget {
  const DetailsPage(this.record, {super.key});
  final Record record;

  @override
  Widget build(BuildContext context) {
    final image = record.photo == null ? null : File(record.photo!);
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (image != null)
            Image.file(
              image,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          const SizedBox(height: 20),
          Text(
            'Data e hora: ${formatDate(record.date)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text('Latitude: ${record.lat}\nLongitude: ${record.lng}'),
          const SizedBox(height: 12),
          Text('Observação: ${record.note.isEmpty ? 'Nenhuma' : record.note}'),
          const SizedBox(height: 12),
          Text(
            'Foto salva em: ${record.photo ?? 'Nenhuma'}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
