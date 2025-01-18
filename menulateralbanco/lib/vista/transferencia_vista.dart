import 'package:flutter/material.dart';
import '../controlador/transferencia_controlador.dart';
import '../modelo/transferencia_modelo.dart';
import 'inicio_vista.dart';
import 'transferencia_exitosa_vista.dart';

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
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _bancoSeleccionado = 'Banco BaPiRiYa';
  String _tipoCuentaSeleccionado = 'Cuenta de Ahorros';
  String _resultado = '';
  late double _comision;
  late double _saldo;

  @override
  void initState() {
    super.initState();
    _comision = 0.0;
    _saldo = widget.controlador.saldo; // Inicializar con el saldo disponible
  }

  void _actualizarComision(String banco) {
    setState(() {
      _comision = (banco == 'Banco BaPiRiYa') ? 0.0 : 0.41;
    });
  }

  void _realizarTransferencia() {
    // Validar datos obligatorios
    if (_cuentaController.text.isEmpty ||
        _nombreController.text.isEmpty ||
        _cedulaController.text.isEmpty ||
        _montoController.text.isEmpty) {
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
                  monto: monto,
                  cuenta: _cuentaController.text,
                  nombre: _nombreController.text,
                  cedula: _cedulaController.text,
                  banco: _bancoSeleccionado,
                  tipoCuenta: _tipoCuentaSeleccionado,
                  descripcion: _descripcionController.text,
                  correo: _correoController.text,
                  comision: _comision,
                );

                final resultado =
                    widget.controlador.realizarTransferencia(transferencia);
                setState(() {
                  _resultado = resultado;
                });
                
                // Redirigir a la página de éxito
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransferenciaExitosaVista(controlador: widget.controlador),
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
            Text('Selecciona el banco de destino', style: TextStyle( color: const Color.fromARGB(213, 19, 19, 19), fontSize: 14),),
            Padding(
              padding: const EdgeInsets.all(16.0), // Ajusta el margen según tus necesidades
              child: DropdownButton<String>(
                value: _bancoSeleccionado,
                isExpanded: true,
                items: [
                  'Banco BaPiRiYa',
                  'Produbanco',
                  'Banco Pichincha',
                  'Banco de Guayaquil',
                  'Banco del Pacífico'
                ].map((banco) {
                  return DropdownMenuItem<String>(
                    value: banco,
                    child: Text(banco),
                  );
                }).toList(),
                onChanged: (nuevoBanco) {
                  setState(() {
                    _bancoSeleccionado = nuevoBanco!;
                    _actualizarComision(nuevoBanco);
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            _buildTextField('Número de cuenta', _cuentaController),
            SizedBox(height: 10),
            _buildTextField('Nombre completo', _nombreController),
            SizedBox(height: 10),
            _buildTextField('Cédula', _cedulaController),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _tipoCuentaSeleccionado,
              isExpanded: true,
              items: ['Cuenta de Ahorros', 'Cuenta Corriente'].map((tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (nuevoTipo) {
                setState(() {
                  _tipoCuentaSeleccionado = nuevoTipo!;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Datos de la transferencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreen,
              ),
            ),
            SizedBox(height: 10),
            _buildTextField('Monto a transferir', _montoController,
                inputType: TextInputType.number),
            SizedBox(height: 10),
            _buildTextField('Correo electrónico (opcional)', _correoController),
            SizedBox(height: 10),
            _buildTextField('Descripción (opcional)', _descripcionController),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                //ir a inicio_vista.dart
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InicioVista()),
                  );
                },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: _realizarTransferencia,
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




