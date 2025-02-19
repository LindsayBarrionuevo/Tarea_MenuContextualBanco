import 'package:flutter/material.dart';
import 'package:menulateral/vista/login.dart';
import 'package:provider/provider.dart';
import 'package:menulateral/vista/inicio_vista.dart';
import './providers/UserProvider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banco BaPiRiYa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Login(),
        '/home': (context) => InicioVista(),
      },
    );
  }
}
