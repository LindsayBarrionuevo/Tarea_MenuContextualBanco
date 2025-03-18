import 'package:flutter/material.dart';

class FlexiAhorroVista extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController montoController = TextEditingController();
    final TextEditingController diaDebitoController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Banco BaPiRiYa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 0, 77, 21),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FlexiAhorro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 77, 21),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Ingreso de datos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 229, 245, 233),
                  backgroundBlendMode: BlendMode.colorDodge,
                  border: Border.all(
                    color: const Color.fromARGB(255, 17, 154, 54),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gana el 5% de interés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- Tu dinero disponible siempre\n'
                      '- Recibe el interés todos los meses\n'
                      '- Aporta y retira las veces que quieras',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                '¿Cuánto quieres ahorrar mensual?',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              SizedBox(height: 10),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Monto (Desde \$1)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: diaDebitoController,
                decoration: InputDecoration(
                  labelText: 'Día de débito',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('¡Éxito!'),
                          content: Text('Gracias por comenzar con FlexiAhorro.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Cierra el diálogo
                                Navigator.of(context).pop(); // Regresa a la página principal
                              },
                              child: Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 77, 21),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
