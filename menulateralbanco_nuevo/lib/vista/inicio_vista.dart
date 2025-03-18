import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:menulateralbanco_nuevo/providers/UserProvider.dart';
import 'package:menulateralbanco_nuevo/vista/pago_servicios_vista.dart';
import 'package:menulateralbanco_nuevo/vista/tarjetas_credito_vista.dart';
import 'package:provider/provider.dart';
import '../controlador/transferencia_controlador.dart';
import 'flexiahorro_vista.dart';
import 'inversiondigital_vista.dart';
import 'transferencia_vista.dart';

class InicioVista extends StatefulWidget {
  final TransferenciaControlador? controlador;

  InicioVista({this.controlador});

  @override
  _InicioVistaState createState() => _InicioVistaState();
}

class _InicioVistaState extends State<InicioVista> {
  late TransferenciaControlador _controlador;
  String _numeroCuenta = '0';
  late double _saldoDisponible; // Saldo disponible
  bool _verSaldo = true; // Controla la visibilidad del saldo
  int _selectedIndex = 0;
  late UserProvider userProvider;
  List<Map<String, dynamic>> _notificaciones = [];

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _controlador = widget.controlador ?? TransferenciaControlador();
    _saldoDisponible = userProvider.user?.balance ?? 0.0;
    _numeroCuenta = userProvider.user?.accountNumber ?? '0';
    _fetchPaymentHistory();
  }

  void toggleSaldo() {
    setState(() {
      _verSaldo = !_verSaldo;
    });
  }

  void actualizarSaldo() {
    setState(() {
      _saldoDisponible = userProvider.user?.balance ?? 0.0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Lógica para la página de inicio
        break;
      case 1:
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Ubícanos'),
              content: Text(
                  'Muy pronto estaremos en todas las provincias del Ecuador, ¡Mantente atento a lo que está por venir!.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Estela'),
              content: Text(
                  'Nuestra asistente virtual está por llegar, ¡Mantente atento a lo que está por venir!.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
        break;
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
          // Limitar a los 3 últimos movimientos
          _notificaciones = jsonList
              .take(3)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      } else {
        setState(() {
          _notificaciones = [];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banco BaPiRiYa',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            )),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                //Mostrar las notificaciones
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Notificaciones'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _notificaciones
                          .map(
                            (notificacion) => ListTile(
                              title: Text("Movimiento desde: " + notificacion['card_number']),
                              subtitle: Text(
                                notificacion['created_at'] + ". Con el monto de: " + notificacion['amount'].toString(),
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.person_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción para el icono de usuario
            },
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: const Color.fromARGB(255, 211, 0, 0),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 77, 21),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo o icono del banco

                  Text(
                    'Banca Digital \nBaPiRiYa',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Ítems del menú
            _buildMenuItem(Icons.grid_view, 'Resumen', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InicioVista(),
                ),
              );
            }),
            _buildMenuItem(Icons.payment, 'Tarjetas de crédito', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TarjetasCreditoVista(),
                ),
              );
            }),
            _buildMenuItem(Icons.receipt, 'Pago de servicios', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PagosServiciosVista(),
                ),
              );
            }),
            _buildMenuItem(
              Icons.send,
              'Transferencias',
              () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TransferenciaVista(controlador: _controlador),
                  ),
                );
                actualizarSaldo();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo al usuario
              Text(
                'Hola, ${userProvider.user?.email.split('@').first ?? 'Usuario'}',
                style: TextStyle(
                  fontSize: 38,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Último ingreso' +
                    ' ${userProvider.user?.createdAt.day}/${userProvider.user?.createdAt.month}/${userProvider.user?.createdAt.year}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 15),

              Card(
                elevation: 5.0,
                margin: EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                textAlign: TextAlign.left,
                                'Cuenta Digital',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              _verSaldo
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: toggleSaldo,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5),
                              Text(
                                'Disponible',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 26, 25, 25),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                _verSaldo
                                    ? '€${userProvider.user?.balance.toStringAsFixed(2) ?? '0.00'}'
                                    : '€***.**',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Saldo por efectivizar: €0.00',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 26, 25, 25),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(
                          height: 30, thickness: 1, color: Colors.grey[300]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'N.º $_numeroCuenta',
                            style: TextStyle(
                                fontSize: 20, color: Colors.green[800]),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.share,
                              color: Colors.green[800],
                            ),
                            onPressed: () {
                              // Acción al presionar el ícono de compartir
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text(
                'Productos para ti',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  _buildProductCard(
                    'FlexiAhorro',
                    'Comienza a ganar el 5% con tus ahorros desde el día 1',
                    Icons.savings,
                    const Color.fromARGB(255, 46, 125, 50),
                    () {
                      // Navegar a la página de FlexiAhorro
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FlexiAhorroVista()),
                      );
                    },
                  ),
                  SizedBox(height: 8), // Espacio entre tarjetas
                  _buildProductCard(
                    'Inversión Digital',
                    'Haz crecer tu dinero con una tasa preferencial',
                    Icons.trending_up,
                    const Color.fromARGB(255, 46, 125, 50),
                    () {
                      // Navegar a la página de Inversión Digital

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InversionDigitalVista()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Ubícanos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            label: 'Estela',
          ),
        ],
        currentIndex: _selectedIndex, // Índice seleccionado
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, // Método para manejar el cambio de índice
      ),
    );
  }

  Widget _buildProductCard(
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap // Aquí pasamos la función onTap como parámetro
      ) {
    return GestureDetector(
      onTap: onTap, // Usamos el onTap pasado como parámetro
      child: Container(
        height: 100, // Altura fija compacta
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2), // Sombra ligera debajo
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Icon(icon, size: 30, color: color),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.arrow_forward_ios,
                  size: 16, color: const Color.fromARGB(255, 46, 125, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[800]), // Color de los íconos
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      onTap: onTap, // Acción al tocar
    );
  }
}
