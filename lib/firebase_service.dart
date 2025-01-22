import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();


  Stream<Map<String, dynamic>> getSensorData() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        return {
          'temperature': data['temperature'] ?? 0.0,
          'ethylene': data['ethylene'] ?? 0.0,
        };
      }
      return {'temperature': 0.0, 'ethylene': 0.0};
    });
  }
}
