import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void setupFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Notificación recibida: ${message.notification!.title}');
      print(' Cuerpo: ${message.notification!.body}');

      // 📢 Mostrar un Toast con la notificación
      Fluttertoast.showToast(
        msg: "${message.notification!.title}: ${message.notification!.body}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP, // Se muestra en la parte superior
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print(' Notificación tocada: ${message.notification!.title}');
  });
}
