import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AnalyticsService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Method to log sensor data every 10 minutes
  Future<void> startPeriodicLogging() async {
    // Use a timer to log data every 10 minutes
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _logSensorData();
    });
  }

  // Method to log current sensor data
  Future<void> _logSensorData() async {
    try {
      // Get current timestamp
      final timestamp = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(timestamp);
      final formattedTime = DateFormat('HH:mm:ss').format(timestamp);

      // Fetch latest sensor data from Firebase
      final sensorDataSnapshot = await _database.child('sensors/latest').get();
      
      if (sensorDataSnapshot.exists) {
        final sensorData = sensorDataSnapshot.value as Map<dynamic, dynamic>;
        
        // Prepare data for logging
        final logEntry = {
          'timestamp': timestamp.toIso8601String(),
          'date': formattedDate,
          'time': formattedTime,
          'temperature': sensorData['temperature'] ?? 0.0,
          'ethylene': sensorData['ethylene'] ?? 0.0,
        };

        // Log data to Firebase
        await _database
            .child('analytics/temperature_logs/$formattedDate')
            .push()
            .set(logEntry);
      }
    } catch (e) {
      debugPrint('Error logging sensor data at ${DateTime.now()}: $e');
    }
  }

  // Method to retrieve historical logs
  Future<List<Map<String, dynamic>>> getTemperatureLogs(String date) async {
    try {
      final logsSnapshot = await _database
          .child('analytics/temperature_logs/$date')
          .get();

      if (logsSnapshot.exists) {
        final logsMap = logsSnapshot.value as Map<dynamic, dynamic>;
        return logsMap.values.map((log) => Map<String, dynamic>.from(log)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error retrieving logs for $date: $e');
      return [];
    }
  }

  // Method to generate daily summary
  Future<Map<String, dynamic>> getDailySummary(String date) async {
    final logs = await getTemperatureLogs(date);
    
    if (logs.isEmpty) {
      return {
        'averageTemperature': 0.0,
        'averageEthylene': 0.0,
        'maxTemperature': 0.0,
        'minTemperature': 0.0,
      };
    }

    final temperatures = logs.map((log) => log['temperature'] as double);
    final ethyleneReadings = logs.map((log) => log['ethylene'] as double);

    return {
      'averageTemperature': _calculateAverage(temperatures),
      'averageEthylene': _calculateAverage(ethyleneReadings),
      'maxTemperature': temperatures.reduce((a, b) => a > b ? a : b),
      'minTemperature': temperatures.reduce((a, b) => a < b ? a : b),
    };
  }

  // Utility method to calculate average
  double _calculateAverage(Iterable<double> values) {
    return values.isEmpty 
      ? 0.0 
      : values.reduce((a, b) => a + b) / values.length;
  }
}