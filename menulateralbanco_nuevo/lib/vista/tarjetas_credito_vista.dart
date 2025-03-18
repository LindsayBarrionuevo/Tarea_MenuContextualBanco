import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../modelo/card_model.dart';
import '../providers/UserProvider.dart';

class TarjetasCreditoVista extends StatefulWidget {
  @override
  _TarjetasCreditoVistaState createState() => _TarjetasCreditoVistaState();
}

class _TarjetasCreditoVistaState extends State<TarjetasCreditoVista> {
  Future<List<CardModel>>? _futureCard;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.id;
    if (userId != null) {
      _futureCard = fetchCards(userId);
    }
  }

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

  Future<void> eliminarTarjeta(int cardId) async {
    final response =
        await http.delete(Uri.parse('http://192.168.137.1:9090/api/cards/$cardId'));
    if (response.statusCode == 200) {
      setState(() {
        _futureCard = fetchCards(
            Provider.of<UserProvider>(context, listen: false).user!.id);
      });
    }
  }

  Future<void> toggleFreezeCard(int cardId, bool frozen) async {
    final url =
        'http://192.168.137.1:9090/api/cards/$cardId/${frozen ? "unfreeze" : "freeze"}';
    final response = await http.put(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _futureCard = fetchCards(
            Provider.of<UserProvider>(context, listen: false).user!.id);
      });
    }
  }

  Future<void> crearTarjeta(int userId, String nombre) async {
    final response = await http.post(
      Uri.parse('http://192.168.137.1:9090/api/cards'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "cardHolderName": nombre}),
    );
    if (response.statusCode == 201) {
      setState(() {
        _futureCard = fetchCards(userId);
      });
    }
  }

  void mostrarEliminarTarjetaModal(BuildContext context, int cardId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Tarjeta'),
          content: Text(
              '¿Estás seguro de que quieres eliminar esta tarjeta? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await eliminarTarjeta(cardId);
                Navigator.pop(context);
              },
              child: Text('Eliminar'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }


  void mostrarCrearTarjetaModal(BuildContext context, bool canCreate) {
    if (!canCreate) return;
    TextEditingController nombreController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Crear Nueva Tarjeta'),
          content: TextField(
            controller: nombreController,
            decoration: InputDecoration(
                labelText: 'Nombre del Titular', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final userId =
                    Provider.of<UserProvider>(context, listen: false).user?.id;
                if (userId != null && nombreController.text.isNotEmpty) {
                  await crearTarjeta(userId, nombreController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Crear'),
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
          backgroundColor: Colors.green[800]),
      body: FutureBuilder<List<CardModel>>(
        future: _futureCard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tarjetas disponibles.'));
          }
          bool canCreate = snapshot.data!.length < 2;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final card = snapshot.data![index];
                    return _buildCardWidget(card);
                  },
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: canCreate
                    ? () => mostrarCrearTarjetaModal(context, canCreate)
                    : null,
                child: Text('Crear Tarjeta'),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardWidget(CardModel card) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 0, 84, 22),
            const Color.fromARGB(255, 35, 113, 56),
            const Color.fromARGB(255, 71, 128, 86),
            const Color.fromARGB(255, 95, 147, 109),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
          Text('Tarjeta de Crédito',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 10),
          Text(
              '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2)),
          SizedBox(height: 5),
          Text('Válida hasta: ${card.expirationDate}',
              style: TextStyle(fontSize: 16, color: Colors.white70)),
          SizedBox(height: 5),
          Text('Nombre: ${card.cardHolderName}',
              style: TextStyle(fontSize: 16, color: Colors.white70)),
          SizedBox(height: 10),
          Text('Estado: ${card.frozen ? 'Congelada' : 'Activa'}',
              style: TextStyle(fontSize: 16, color: Colors.white70)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => toggleFreezeCard(card.id, card.frozen),
                child: Text(card.frozen ? 'Descongelar' : 'Congelar',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 6, 73, 0)),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => mostrarEliminarTarjetaModal(context, card.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
