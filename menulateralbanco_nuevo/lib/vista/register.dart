import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/UserProvider.dart';
import '../modelo/card_model.dart'; // Add this line to import CardModel

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController nombreTarjetaController = TextEditingController();
  String _errorMessage = '';
  Future<List<CardModel>>? _futureCard;

  Future<void> crearTarjeta(int userId, String nombre) async {
    final response = await http.post(
      Uri.parse('http://192.168.137.1:9090/api/cards'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "cardHolderName": nombre}),
    );
  }

  Future<int?> _register() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, llena todos los campos';
      });
      return null;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return null;
    }

    // Preparar los datos para el registro
    final Map<String, dynamic> userData = {
      'email': email,
      'password_hash': password,
    };

    // Enviar la solicitud POST al backend
    final response = await http.post(
      Uri.parse('http://192.168.137.1:9090/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["id"]; // Retornar el userId del usuario creado
    } else {
      // Si hay un error en la respuesta
      setState(() {
        _errorMessage = 'Error en el registro. Intenta nuevamente';
      });
      return null;
    }
  }

  void _handleRegister() async {
    final userId =
        await _register(); // Esperamos a que el usuario se registre y obtenemos el userId
    if (userId != null && nombreTarjetaController.text.isNotEmpty) {
      await crearTarjeta(userId, nombreTarjetaController.text);
      Navigator.pop(context);
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
                labelStyle:
                    TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
                labelStyle:
                    TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirmar Contraseña',
                labelStyle:
                    TextStyle(color: const Color.fromARGB(255, 0, 77, 21)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nombreTarjetaController,
              decoration: InputDecoration(
                  labelText: 'Nombre del Titular',
                  border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _handleRegister,
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
