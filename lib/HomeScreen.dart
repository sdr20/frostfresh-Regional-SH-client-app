import 'package:flutter/material.dart';
import 'firebase_service.dart'; // Import the FirebaseService

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  double temperature = 0.0;
  double ethylene = 0.0;
  
  // Editable warning messages
  String lowTempMessage = "Temperature is too low! Please check the cooling system.";
  String highTempMessage = "DANGER: Temperature is critically high! Immediate action required.";
  String ethyleneWarningMessage = "Ethylene detected! Ensure proper ventilation and check for ripening produce.";

  @override
  void initState() {
    super.initState();
    // No need to listen here since StreamBuilder will handle it
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Warning'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildThermometer(double temperature) {
    Color tempColor = temperature >= 60 
        ? Colors.red 
        : temperature <= 30 
            ? Colors.blue 
            : Colors.orange;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850], // Dark background color
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Temperature',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark mode
            ),
          ),
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 40,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 40,
                  height: (temperature / 100) * 200,
                  decoration: BoxDecoration(
                    color: tempColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                right: -70,
                child: Text(
                  '${temperature.toStringAsFixed(1)}°F',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for dark mode
                  ),
                ),
              ),
            ],
          ),
          if (temperature <= 30)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: InkWell(
                onTap: () => _showWarningDialog(lowTempMessage),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Low Temperature Warning',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),
          if (temperature >= 60)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'DANGER ZONE',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEthyleneSensor(double ethylene) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850], // Dark background color
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ethylene Level',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark mode
            ),
          ),
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[600],
                ),
                child: Center(
                  child: Text(
                    ethylene.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ethylene > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
              if (ethylene > 0)
                Positioned(
                  bottom: 20,
                  child: InkWell(
                    onTap: () => _showWarningDialog(ethyleneWarningMessage),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Ethylene Detected',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frost Fresh'),
        centerTitle: true, 
        elevation: 0,
        backgroundColor: Colors.black, // Dark background for AppBar
        foregroundColor: Colors.white, // White text in AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // settings functionality here
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black, // Dark background color
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _firebaseService.getSensorData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            }

            if (snapshot.hasData) {
              final data = snapshot.data!;
              temperature = data['temperature'];
              ethylene = data['ethylene'];

              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildThermometer(temperature),
                  SizedBox(height: 20),
                  _buildEthyleneSensor(ethylene),
                ],
              );
            }

            return Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
          },
        ),
      ),
    );
  }
}
