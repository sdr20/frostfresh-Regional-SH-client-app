import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'firebase_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  double _temperature = 0.0;
  double _ethylene = 0.0;
  bool _relayState = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _listenToSensorData();
  }

  void _listenToSensorData() {
    _firebaseService.getSensorData().listen((data) {
      setState(() {
        _temperature = data['temperature'];
        _ethylene = data['ethylene'];
        _relayState = data['relayState'];
      });
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.grey[850]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[850],
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FrostFresh',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateHeader(),
              SizedBox(height: 20),
              _buildSummaryCard(),
              SizedBox(height: 20),
              _buildDetailedSummaryCard(),
              SizedBox(height: 20),
              _buildRelayState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Center(
      child: Text(
        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGauge('Temperature', _temperature, 100, const Color.fromARGB(255, 129, 179, 255), true),
          _buildEthyleneGauge('Ethylene', _ethylene, 400, Colors.green),
        ],
      ),
    );
  }

  Widget _buildDetailedSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildSummaryRow('Max Temperature', '${_temperature.toStringAsFixed(1)}°F'),
          _buildSummaryRow('Min Temperature', '${_temperature.toStringAsFixed(1)}°F'),
          _buildSummaryRow('Max Ethylene', '${_ethylene.toStringAsFixed(1)} ppm'),
          _buildSummaryRow('Min Ethylene', '${_ethylene.toStringAsFixed(1)} ppm'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelayState() {
    return Container(
      width: double.infinity,  // Make the container take the full width
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Relay State',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _relayState ? 'ON' : 'OFF',
            style: TextStyle(
              color: _relayState ? Colors.green : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(String label, double value, double maxValue, Color color, bool isTemperature) {
    return Container(
      width: double.infinity,  
      height: 200, 
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: maxValue,
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.2,
                    color: color.withOpacity(0.5),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: value,
                      width: 0.2,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: color,
                    ),
                    NeedlePointer(
                      value: value,
                      needleLength: 0.8,
                      lengthUnit: GaugeSizeUnit.factor,
                      needleColor: color,
                      knobStyle: KnobStyle(
                        color: color,
                        sizeUnit: GaugeSizeUnit.factor,
                        knobRadius: 0.05,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Container(
                        child: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEthyleneGauge(String label, double value, double maxValue, Color color) {
    return Container(
      width: double.infinity,  
      height: 200, 
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: maxValue,
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 250, color: Colors.green, startWidth: 10, endWidth: 10),
                    GaugeRange(startValue: 250, endValue: 400, color: Colors.red, startWidth: 10, endWidth: 10),
                  ],
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.2,
                    color: color.withOpacity(0.5),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: value,
                      width: 0.2,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: color,
                    ),
                    NeedlePointer(
                      value: value,
                      needleLength: 0.8,
                      lengthUnit: GaugeSizeUnit.factor,
                      needleColor: color,
                      knobStyle: KnobStyle(
                        color: color,
                        sizeUnit: GaugeSizeUnit.factor,
                        knobRadius: 0.05,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Container(
                        child: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}