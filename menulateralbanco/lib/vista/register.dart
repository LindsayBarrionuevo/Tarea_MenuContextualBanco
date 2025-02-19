import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorMessage = '';

  Future<void> _register() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, llena todos los campos';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    // Preparar los datos para el registro
    final Map<String, dynamic> userData = {
      'email': email,
      'password_hash': password,
    };

    // Enviar la solicitud POST al backend
    final response = await http.post(
      Uri.parse('http://localhost:9090/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      setState(() {
        _errorMessage = ''; // Limpiar mensaje de error si todo es exitoso
      });
      Navigator.pop(context); // Volver a la pantalla de login
    } else {
      // Si hay un error en la respuesta
      setState(() {
        _errorMessage = 'Error en el registro. Intenta nuevamente';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21),
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
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirmar Contraseña',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 0, 77, 21),
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
          ],
        ),
      ),
    );
  }
}
