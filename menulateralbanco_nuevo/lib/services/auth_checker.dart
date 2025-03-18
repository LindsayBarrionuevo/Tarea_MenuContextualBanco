import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:menulateralbanco_nuevo/vista/login.dart';
import '../vista/google_sign_in.dart';

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => GoogleSignInPage()));
    } else {
 Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
