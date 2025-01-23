import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Stream to get sensor data from Firebase Realtime Database.
  /// The data includes temperature and ethylene levels.
  Stream<Map<String, dynamic>> getSensorData() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data != null) {
        return {
          'temperature': (data['temperature'] as num?)?.toDouble() ?? 0.0,
          'ethylene': (data['ethylene'] as num?)?.toDouble() ?? 0.0,
        };
      }
      return {'temperature': 0.0, 'ethylene': 0.0};
    }).handleError((error) {
      print('Error retrieving sensor data: $error');
      return {'temperature': 0.0, 'ethylene': 0.0};
    });
  }
}