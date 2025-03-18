import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart'; // Update with the correct path to your LoginPage file

class GoogleSignInPage extends StatefulWidget {
  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    _checkUserAuthStatus();
  }

  Future<void> _checkUserAuthStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // El usuario ya está autenticado, redirige al login del banco directamente
      // Redirigir al login del banco
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user != null) {
        // Obtener token FCM
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          print("FCM Token: $fcmToken");

          // Guardar datos en Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .set({
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'fcmToken': fcmToken,
          });

          // Redirigir al login del banco
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
        } else {
          print("No se pudo obtener el FCM Token");
        }
      }
    } catch (e) {
      print("Error en Google Sign-In: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Autenticación con Google")),
      body: Center(
        child: ElevatedButton(
          onPressed: _signInWithGoogle,
          child: Text("Iniciar sesión con Google"),
        ),
      ),
    );
  }
}
