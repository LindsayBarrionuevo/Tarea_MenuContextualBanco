import 'package:flutter/material.dart';
import '../controlador/transferencia_controlador.dart';
import 'transferencia_vista.dart';

class InicioVista extends StatefulWidget {
  @override
  _InicioVistaState createState() => _InicioVistaState();
}

class _InicioVistaState extends State<InicioVista> {
  final TransferenciaControlador _controlador = TransferenciaControlador();
  final String _numeroCuenta = '1234567890'; // Número de cuenta
  late double _saldoDisponible; // Saldo disponible
  bool _verSaldo = true; // Controla la visibilidad del saldo

  void toggleSaldo() {
    setState(() {
      _verSaldo = !_verSaldo;
    });
  }

  void initState() {
    super.initState();
    _saldoDisponible = _controlador.saldo;
  }

  void actualizarSaldo() {
    setState(() {});
    _saldoDisponible = _controlador.saldo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        title: Text(
          'Banco BaPiRiYa',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.yellow[700],
              ),
              child: Text(
                'Menú Principal',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.send, color: Colors.green[800]),
              title: Text('Transferir Dinero'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferenciaVista(controlador: _controlador),
                  ),
                );
                actualizarSaldo();
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Colors.green[800]),
              title: Text('Pagar Servicios'),
              onTap: () {
                // Acción al presionar "Pagar Servicios"
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.green[800]),
              title: Text('Pagar Tarjetas'),
              onTap: () {
                // Acción al presionar "Pagar Tarjetas"
              },
            ),
            ListTile(
              leading: Icon(Icons.more_horiz, color: Colors.green[800]),
              title: Text('Todas las Operaciones'),
              onTap: () {
                // Acción al presionar "Todas las Operaciones"
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
                'Hola, Usuario',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Sección "Mis productos"
              Text(
                'Mis productos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cuenta Digital',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'N.° $_numeroCuenta',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _verSaldo
                                ? 'Saldo Disponible: \$${_saldoDisponible.toStringAsFixed(2)}'
                                : 'Saldo Disponible: *****',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800]),
                          ),
                          IconButton(
                            icon: Icon(
                              _verSaldo ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[700],
                            ),
                            onPressed: toggleSaldo,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
