import 'dart:convert';
import 'dart:io';
//import 'dart:typed_data';
//import 'dart:html' as html;

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:menulateralbanco_nuevo/modelo/card_model.dart';
import 'package:provider/provider.dart';
import 'package:menulateralbanco_nuevo/providers/UserProvider.dart';

class PagosServiciosVista extends StatefulWidget {
  @override
  _PagosServiciosVistaState createState() => _PagosServiciosVistaState();
}

class _PagosServiciosVistaState extends State<PagosServiciosVista> {
  final TextEditingController _montoController = TextEditingController();

  late UserProvider userProvider;
  List<Map<String, dynamic>> paymentHistory = [];

  double userBalance = 0;

  List<String> userCards = [];

  Future<List<CardModel>> fetchCards(int userId) async {
    final response =
        await http.get(Uri.parse('http://192.168.137.1:9090/api/cards/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => CardModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las tarjetas');
    }
  }

  Future<void> _fetchPaymentHistory() async {
    final userId = userProvider.user?.id;
    if (userId != null) {
      final response = await http.get(
        Uri.parse('http://192.168.137.1:5000/api/transactions?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          paymentHistory =
              jsonList.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        _mostrarMensaje('Error al obtener el historial de pagos');
      }
    }
  }

  // Future<void> _descargarHistorialPdf() async {
  //   try {
  //     // Realizamos la solicitud al backend para obtener el PDF
  //     final response = await http
  //         .get(Uri.parse('http://192.168.137.1:5000/api/transactions/pdf'));

  //     if (response.statusCode == 200) {
  //       // Obtenemos los bytes del archivo PDF
  //       final bytes = response.bodyBytes;

  //       // Creamos un objeto Blob a partir de los bytes del archivo
  //       final blob = html.Blob([Uint8List.fromList(bytes)]);

  //       // Generamos una URL para el Blob
  //       final url = html.Url.createObjectUrlFromBlob(blob);

  //       // Creamos un enlace de descarga
  //       final anchor = html.AnchorElement(href: url)
  //         ..target = 'blank'
  //         ..download = 'transactions.pdf'
  //         ..click();

  //       // Limpiamos la URL después de la descarga
  //       html.Url.revokeObjectUrl(url);
  //     } else {
  //       // Si la solicitud falla, mostramos un mensaje
  //       _mostrarMensaje('Error al descargar el PDF');
  //     }
  //   } catch (e) {
  //     // Capturamos errores en la solicitud HTTP
  //     _mostrarMensaje('Error en la solicitud: $e');
  //   }
  // }

  Future<void> _descargarHistorialPdf() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.137.1:5000/api/transactions/pdf'));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      // Obtiene la ruta del directorio de almacenamiento
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/transactions.pdf';

      // Guarda el archivo en el almacenamiento
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Abre el archivo PDF
      await OpenFile.open(filePath);
      
      _mostrarMensaje('PDF descargado y abierto exitosamente');
    } else {
      _mostrarMensaje('Error al descargar el PDF');
    }
  } catch (e) {
    _mostrarMensaje('Error en la solicitud: $e');
  }
}

  @override
  void initState() {
    super.initState();
    // Instanciamos el provider para obtener el balance
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userBalance =
        userProvider.user?.balance ?? 0.0; // Asignamos el balance del usuario

    // Obtenemos las tarjetas del usuario
    final userId = userProvider.user?.id;
    if (userId != null) {
      fetchCards(userId).then((cards) {
        setState(() {
          userCards = cards.map((card) => card.cardNumber).toList();
        });
      });
    }

    userProvider = Provider.of<UserProvider>(context, listen: false);
    _fetchPaymentHistory();
  }


  String? _selectedCard;

  void _mostrarModalPago() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nuevo Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monto a pagar'),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCard,
                hint: Text('Seleccionar tarjeta'),
                items: userCards.map((card) {
                  return DropdownMenuItem<String>(
                    value: card,
                    child: Text(card.replaceRange(0, 12, '**** **** **** ')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCard = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _procesarPago,
              child: Text('Pagar'),
            ),
          ],
        );
      },
    );
  }

  void _procesarPago() async {
    double? monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      _mostrarMensaje('Monto inválido');
      return;
    }
    if (monto > userBalance) {
      _mostrarMensaje('Saldo insuficiente');
      return;
    }
    if (_selectedCard == null) {
      _mostrarMensaje('Debe seleccionar una tarjeta');
      return;
    }

    // Llamar al API para procesar el pago
    final userId = userProvider.user?.id; // Asegúrate de tener el userId
    if (userId == null) {
      _mostrarMensaje('Usuario no encontrado');
      return;
    }

    final response = await http.post(
      Uri.parse(
          'http://192.168.137.1:5000/api/payments'), // Asegúrate de usar la URL correcta
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'amount': monto,
        'card_number': _selectedCard,
      }),
    );

    if (response.statusCode == 200) {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      userProvider.user!.balance -= monto;
      _mostrarMensaje('Pago realizado con éxito');
    } else {
      final error = jsonDecode(response.body);
      _mostrarMensaje('Error: ${error['error']}');
    }

    Navigator.pop(context);
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banco BaPiRiYa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Pagos',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.4), blurRadius: 8)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Realiza un nuevo pago',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _mostrarModalPago,
                      child: Text('Nuevo Pago'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Sección de Programar pagos
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Programa tus pagos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Simplifica tus pagos y ahorra tiempo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 58, 119, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        // Acción para programar un pago
                      },
                      child: Text(
                        'Nueva Programación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Conoce sobre los nuevos pagos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Sección de Historial de pagos
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de pagos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    paymentHistory.isEmpty
                        ? Text(
                            'No existe ningún pago registrado.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: paymentHistory.length,
                            itemBuilder: (context, index) {
                              var payment = paymentHistory[index];
                              return ListTile(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8),
                                title: Text(
                                  'Monto: \$${payment['amount']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Tarjeta o Cuenta: ${payment['card_number'].substring(0, 4)}**** **** ${payment['card_number'].length > 12 ? payment['card_number'].substring(12) : ""}\nFecha: ${payment['created_at']}\nEstado: ${payment['status']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),

                                tileColor: Colors.grey[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            },
                          ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _descargarHistorialPdf,
                      child: Text('Descargar Historial de Pagos en PDF'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
