import 'package:flutter/material.dart';
import '../controlador/transferencia_controlador.dart';
import '../modelo/transferencia_modelo.dart';

class TransferenciaVista extends StatefulWidget {
  final TransferenciaControlador controlador;

  TransferenciaVista({required this.controlador});

  @override
  _TransferenciaVistaState createState() => _TransferenciaVistaState();
}

class _TransferenciaVistaState extends State<TransferenciaVista> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _cuentaController = TextEditingController();
  String _resultado = '';

  void realizarTransferencia() {
    final double monto = double.parse(_montoController.text);
    final String cuenta = _cuentaController.text;

    if (_montoController.text.isEmpty || _cuentaController.text.isEmpty) {
      setState(() {
        _resultado = 'Por favor ingrese todos los datos';
      });
      return;
    }

    final transferencia = TransferenciaModelo(monto: monto, cuenta: cuenta);
    final resultado = widget.controlador.realizarTransferencia(transferencia);
    setState(() {
      _resultado = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Transferencia'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cuentaController,
              decoration: InputDecoration(
                labelText: 'Número de Cuenta',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monto a Transferir',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: realizarTransferencia,
              child: Text('Transferir'),
            ),
            SizedBox(height: 20),
            Text(_resultado, style: TextStyle(fontSize: 24.0, color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }
}