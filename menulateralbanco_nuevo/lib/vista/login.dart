import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:menulateralbanco_nuevo/vista/google_sign_in.dart';
import 'package:menulateralbanco_nuevo/vista/inicio_vista.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Future<void> _login() async {
  //   final String email = _emailController.text.trim();
  //   final String password = _passwordController.text;

  //   if (email.isEmpty || password.isEmpty) {
  //     setState(() {
  //       _errorMessage = 'Por favor, ingresa ambos campos';
  //     });
  //     return;
  //   }

  //   final response =
  //       await http.get(Uri.parse('http://192.168.137.1:9090/api/users'));

  //   if (response.statusCode == 200) {
  //     List<dynamic> users = json.decode(response.body);

  //     var user = users.firstWhere(
  //       (u) => u['email'] == email && u['password_hash'] == password,
  //       orElse: () => null,
  //     );

  //     if (user != null) {
  //       UserModel loggedInUser = UserModel.fromJson(user);

  //       // Guardar en el Provider
  //       Provider.of<UserProvider>(context, listen: false).setUser(loggedInUser);

  //       // Obtener usuario autenticado con Google
  //       User? googleUser = FirebaseAuth.instance.currentUser;

  //       if (googleUser != null) {
  //         // Relacionar en Firestore
  //         await FirebaseFirestore.instance
  //             .collection('user_links')
  //             .doc(email)
  //             .set({
  //           'bank_email': email,
  //           'google_email': googleUser.email,
  //           'fcmToken': await FirebaseMessaging.instance.getToken(),
  //         });
  //       }

  //       // Redirigir al login del banco
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => InicioVista()),
  //       );
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Email o contraseña incorrectos';
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _errorMessage = 'Error en la conexión con el servidor';
  //     });
  //   }
  // }

  // Future<void> _login() async {
  //   final String email = _emailController.text.trim();
  //   final String password = _passwordController.text;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Intentando iniciar sesión...")),
  //   );

  //   if (email.isEmpty || password.isEmpty) {
  //     setState(() {
  //       _errorMessage = 'Por favor, ingresa ambos campos';
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Campos vacíos")),
  //     );
  //     return;
  //   }

  //   try {
  //     final response =
  //         await http.get(Uri.parse('http://192.168.137.1:9090/api/users'));

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Código de respuesta: ${response.statusCode}")),
  //     );

  //     if (response.statusCode == 200) {
  //       List<dynamic> users = json.decode(response.body);

  //       var user = users.firstWhere(
  //         (u) => u['email'] == email && u['password_hash'] == password,
  //         orElse: () => null,
  //       );

  //       if (user != null) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Usuario encontrado, iniciando sesión...")),
  //         );

  //         UserModel loggedInUser = UserModel.fromJson(user);
  //         Provider.of<UserProvider>(context, listen: false)
  //             .setUser(loggedInUser);

  //         // Verificar autenticación con Firebase
  //         User? googleUser = FirebaseAuth.instance.currentUser;

  //         if (googleUser != null) {
  //           await FirebaseFirestore.instance
  //               .collection('user_links')
  //               .doc(email)
  //               .set({
  //             'bank_email': email,
  //             'google_email': googleUser.email,
  //             'account_number': loggedInUser.accountNumber,
  //             'fcmToken': await FirebaseMessaging.instance.getToken(),
  //           },SetOptions(merge: true));

  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text("Datos guardados en Firestore")),
  //           );
  //         } else {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text("No se encontró usuario de Google")),
  //           );
  //         }
  //         try {
  //           if (!mounted) return;
  //           Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => InicioVista()));
  //         } catch (e) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text("Error al cambiar de pantalla: $e")),
  //           );
  //         }
  //       } else {
  //         setState(() {
  //           _errorMessage = 'Email o contraseña incorrectos';
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text("Credenciales incorrectas")),
  //         );
  //       }
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Error en la conexión con el servidor';
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Error en la conexión con el servidor")),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'Ocurrió un error, intenta de nuevo';
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $e")),
  //     );
  //   }
  // }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Intentando iniciar sesión...")),
    );

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, ingresa ambos campos';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Campos vacíos")),
      );
      return;
    }

    try {
      final response =
          await http.get(Uri.parse('http://192.168.137.1:9090/api/users'));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Código de respuesta: ${response.statusCode}")),
      );

      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);

        var user = users.firstWhere(
          (u) => u['email'] == email && u['password_hash'] == password,
          orElse: () => null,
        );

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Usuario encontrado, iniciando sesión...")),
          );

          UserModel loggedInUser = UserModel.fromJson(user);
          Provider.of<UserProvider>(context, listen: false)
              .setUser(loggedInUser);

          // Verificar autenticación con Google
          User? googleUser = FirebaseAuth.instance.currentUser;

          if (googleUser != null) {
            //Obtener o actualizar el token FCM
            String? fcmToken = await FirebaseMessaging.instance.getToken();

            await FirebaseFirestore.instance
                .collection('user_links')
                .doc(email)
                .set(
                    {
                  'bank_email': email,
                  'google_email': googleUser.email,
                  'account_number': loggedInUser.accountNumber,
                  'fcmToken': fcmToken,
                },
                    SetOptions(
                        merge:
                            true)); // Usa merge para no sobrescribir datos previos

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Datos guardados en Firestore")),
            );

            //  Redirigir a la pantalla principal
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InicioVista()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "No se encontró usuario de Google. ¿Deseas vincular tu cuenta?"),
                action: SnackBarAction(
                  label: "Vincular",
                  onPressed: () async {
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GoogleSignInPage()),
                    ); // Llamar al login con Google
                  },
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Email o contraseña incorrectos';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Credenciales incorrectas")),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Error en la conexión con el servidor';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error en la conexión con el servidor")),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error, intenta de nuevo';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor:
            const Color.fromARGB(255, 0, 77, 21), // Color verde para la app bar
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
                labelStyle: TextStyle(
                    color:
                        const Color.fromARGB(255, 0, 77, 21)), // Etiqueta verde
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
                labelStyle: TextStyle(
                    color:
                        const Color.fromARGB(255, 0, 77, 21)), // Etiqueta verde
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _login,
              child: Text('Ingresar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    const Color.fromARGB(255, 0, 77, 21), // Botón verde
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
