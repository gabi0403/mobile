import 'package:exemplo_shared_preferences/view/exemplo1_page.dart';
import 'package:exemplo_shared_preferences/view/exemplo2_page.dart';
import 'package:exemplo_shared_preferences/view/exemplo3_page.dart';
import 'package:exemplo_shared_preferences/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
 
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('darkMode') ?? false;
 
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
 
 
  runApp(const MyApp());
}
 
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
 
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
         
          routes: {
            "/tela1": (context) => const Exemplo1Page(),
            "/tela2": (context) => const Exemplo2Page(),
            "/tela3": (context) => const Exemplo3Page(),
          },
          home: const HomePage(),
        );
      },
    );
  }
}