import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/UserProvider.dart';
import '../modelo/user_model.dart';
import 'register.dart'; // Importamos la vista de registro

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa ambos campos';
      });
      return;
    }

    final response =
        await http.get(Uri.parse('http://localhost:9090/api/users'));

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);

      var user = users.firstWhere(
        (u) => u['email'] == email && u['password_hash'] == password,
        orElse: () => null,
      );

      if (user != null) {
        UserModel loggedInUser = UserModel.fromJson(user);

        // Guardar el usuario en el Provider
        Provider.of<UserProvider>(context, listen: false).setUser(loggedInUser);

        Navigator.pushNamed(context, '/home'); // Redirigir a la vista principal
      } else {
        setState(() {
          _errorMessage = 'Email o contraseña incorrectos';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Error en la conexión con el servidor';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21), // Color verde para la app bar
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 77, 21)), // Etiqueta verde
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 77, 21)), // Etiqueta verde
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              child: Text('Ingresar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 0, 77, 21), // Botón verde
              ),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            // Botón para redirigir a la vista de registro
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Register()), // Redirección
                );
              },
              child: Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
