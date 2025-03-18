import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:menulateralbanco_nuevo/providers/UserProvider.dart';
import '../controlador/transferencia_controlador.dart';
import '../modelo/transferencia_modelo.dart';
import 'inicio_vista.dart';
import 'transferencia_exitosa_vista.dart';
import 'package:provider/provider.dart'; // Para acceder al userProvider

class TransferenciaVista extends StatefulWidget {
  final TransferenciaControlador controlador;

  TransferenciaVista({required this.controlador});

  @override
  _TransferenciaVistaState createState() => _TransferenciaVistaState();
}

class _TransferenciaVistaState extends State<TransferenciaVista> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _cuentaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  String _bancoSeleccionado = 'Banco BaPiRiYa';
  String _tipoCuentaSeleccionado = 'Cuenta de Ahorros';
  String _resultado = '';
  late double _comision = 0.41;
  late double _saldo;

  @override
  void initState() {
    super.initState();
    _comision = 0.0;
    _saldo = widget.controlador.saldo; // Inicializar con el saldo disponible
  }

  Future<void> sendPushNotification(
      String token, String sender, double amount) async {
    final url = Uri.parse(
        'http://192.168.137.1:5000/send-notification'); //cambiar la IP si se corre en un servidor

    final data = {
      "token": token,
      "sender": sender,
      "amount": amount,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print("/Notificación enviada con éxito");
    } else {
      print("/ Error: ${response.body}");
    }
  }

  Future<void> realizarTransferencia(
      String receiver, double amount, String sender) async {
    try {
      final url = Uri.parse('http://192.168.137.1:5000/api/transfer');

      final Map<String, dynamic> transferData = {
        'sender': sender,
        'receiver': receiver,
        'amount': amount,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(transferData),
      );

      if (response.statusCode == 200) {
        print(' Transferencia realizada con éxito');

        UserProvider userProvider =
            Provider.of<UserProvider>(context, listen: false);
        userProvider.user!.balance -= amount; // Ajuste sin comisión

        setState(() {
          _resultado = 'Transferencia realizada con éxito';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Transferencia realizada con éxito')),
        );

        // Buscar el token FCM del destinatario
        var userQuery = await FirebaseFirestore.instance
            .collection('user_links')
            .where('account_number', isEqualTo: receiver)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          var recipientData = userQuery.docs.first.data();
          String? recipientFCMToken = recipientData['fcmToken'];

          if (recipientFCMToken != null) {
            await sendPushNotification(recipientFCMToken, sender, amount);
            print("📩 Notificación enviada al destinatario.");
          } else {
            print(" No se encontró el token FCM del destinatario.");
          }
        } else {
          print(" No se encontró el destinatario con esa cuenta.");
        }
      } else {
        print(' Error en la transferencia: ${response.body}');
        setState(() {
          _resultado = 'Error en la transferencia: ${response.body}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(' Error en la transferencia: ${response.body}')),
        );
      }
    } catch (e) {
      print(' Error de conexión: $e');
      setState(() {
        _resultado = 'Error de conexión';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Error de conexión')),
      );
    }
  }

  void _realizarTransferencia(String receiver, double amount, String sender) {
    // Validar datos obligatorios
    if (_cuentaController.text.isEmpty || _montoController.text.isEmpty) {
      setState(() {
        _resultado = 'Por favor ingrese todos los datos obligatorios.';
      });
      return;
    }

    // Validar formato del monto
    double? monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      setState(() {
        _resultado = 'Ingrese un monto válido.';
      });
      return;
    }

    // Verificar si el monto supera el saldo disponible
    if (monto + _comision > _saldo) {
      setState(() {
        _resultado = 'El monto supera el saldo disponible.';
      });
      return;
    }

    // Confirmar transferencia
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar transferencia'),
          content: Text(
              '¿Está seguro de realizar esta transferencia por \$${(monto + _comision).toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                // Procesar la transferencia
                final transferencia = TransferenciaModelo(
                  monto: amount,
                  cuenta_destino: receiver, // Cuenta de destino
                  cuenta_origen: sender, // Cuenta de origen
                  nombre: _nombreController.text,
                  banco: _bancoSeleccionado,
                  tipoCuenta: _tipoCuentaSeleccionado,
                  comision: _comision,
                );

                // Realizar la transferencia a través del controlador
                realizarTransferencia(transferencia.cuenta_destino,
                    transferencia.monto, transferencia.cuenta_origen);

                // Redirigir a la página de éxito
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferenciaExitosaVista(
                        controlador: widget.controlador),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el número de cuenta del usuario a través del provider
    final userProvider = Provider.of<UserProvider>(context);
    final senderAccount = userProvider.user?.accountNumber ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: Text('Banco BaPiRiYa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transferencia Local',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 77, 21),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Información para la transferencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen,
              ),
            ),
            SizedBox(height: 10),
            Text('Cuenta de destino',
                style: TextStyle(
                    color: const Color.fromARGB(213, 19, 19, 19),
                    fontSize: 14)),
            SizedBox(height: 10),
            _buildTextField(
                'Número de cuenta del destinatario', _cuentaController,
                inputType: TextInputType.number),
            SizedBox(height: 10),
            _buildTextField('Monto a transferir', _montoController,
                inputType: TextInputType.number),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InicioVista()),
                    );
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => _realizarTransferencia(
                      _cuentaController.text,
                      double.parse(_montoController.text),
                      senderAccount),
                  child: Text('Transferir'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              _resultado,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
