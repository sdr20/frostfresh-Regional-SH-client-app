import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'homescreen.dart'; 


const String apiKey = "AIzaSyDtTtKcyvDlBdLze4qytggyC0GsIPQZB4k";
const String authDomain = "frostfresh-7de8e.firebaseapp.com";
const String databaseURL = "https://frostfresh-7de8e-default-rtdb.asia-southeast1.firebasedatabase.app";
const String projectId = "frostfresh-7de8e";
// const String storageBucket = "frostfresh-7de8e.firebasestorage.app";
const String messagingSenderId = "705174620428";
const String appId = "1:705174620428:web:81ade7ebdfc887a5096129";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      databaseURL: databaseURL,
      projectId: projectId,
      // storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
    ),
  );

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