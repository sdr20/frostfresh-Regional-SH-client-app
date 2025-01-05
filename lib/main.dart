import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'homescreen.dart';

const String apiKey = "AIzaSyDtTtKcyvDlBdLze4qytggyC0GsIPQZB4k";
const String authDomain = "frostfresh-7de8e.firebaseapp.com";
const String databaseURL = "https://frostfresh-7de8e-default-rtdb.asia-southeast1.firebasedatabase.app";
const String projectId = "frostfresh-7de8e";
const String messagingSenderId = "705174620428";
const String appId = "1:705174620428:web:81ade7ebdfc887a5096129";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseURL,
        projectId: projectId,
        messagingSenderId: messagingSenderId,
        appId: appId,
      ),
    );
  } catch (e) {
  
    print("Firebase is already initialized: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor App',
      home: HomeScreen(),
    );
  }
}
