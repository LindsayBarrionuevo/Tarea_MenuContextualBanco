import 'package:flutter/material.dart';
import 'package:menulateralbanco_nuevo/vista/login.dart';
import 'package:provider/provider.dart';
import 'package:menulateralbanco_nuevo/vista/inicio_vista.dart';
import './providers/UserProvider.dart';
import './services/auth_checker.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de tener este archivo generado correctamente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Asegúrate de tenerlo bien configurado
    );
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banco BaPiRiYa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthCheck(), // Usar AuthCheck como pantalla inicial
    );
  }
}
