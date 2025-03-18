import 'package:flutter/material.dart';
import '../controlador/transferencia_controlador.dart';
import 'inicio_vista.dart';

class TransferenciaExitosaVista extends StatelessWidget {
  final TransferenciaControlador controlador; // Controlador actualizado

  TransferenciaExitosaVista({required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transferencia Exitosa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              '¡Transferencia realizada con éxito!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar a InicioVista con el controlador actualizado
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InicioVista(controlador: controlador),
                  ),
                );
              },
              child: Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}