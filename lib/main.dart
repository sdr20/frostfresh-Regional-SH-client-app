import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homescreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  runApp(MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'frostfresh',
        options: FirebaseOptions(
          apiKey: "AIzaSyDtTtKcyvDlBdLze4qytggyC0GsIPQZB4k",
          authDomain: "frostfresh-7de8e.firebaseapp.com", 
          databaseURL: "https://frostfresh-7de8e-default-rtdb.asia-southeast1.firebasedatabase.app", // Replace with your Firebase Realtime Database URL
          projectId: "frostfresh-7de8e", // Replace with your project ID
          messagingSenderId: "705174620428", // Replace with your messagingSenderId
          appId: "1:705174620428:web:81ade7ebdfc887a5096129", // Replace with your app ID
        ),
      );
      print('Firebase initialized');
    } else {
      print('Firebase already initialized');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sensor App',
      home: HomeScreen(), // Set HomeScreen as the home screen
    );
  }
}