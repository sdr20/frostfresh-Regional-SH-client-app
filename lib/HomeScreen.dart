import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'analytics_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _dailySummary = {};
  List<Map<String, dynamic>> _logs = [];
  final double ethyleneThreshold = 5.0; // Define your ethylene threshold here

  @override
  void initState() {
    super.initState();
    // Initial fetch can be removed if you want it to be fetched only on button press
    //_fetchDailySummary();
  }

  Future<void> _fetchDailySummary() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    setState(() {
      _dailySummary = {
        'averageTemperature': 0.0,
        'averageEthylene': 0.0,
        'maxTemperature': 0.0,
        'minTemperature': 0.0,
        'maxEthylene': 0.0,
        'minEthylene': 0.0,
      };
    });

    final summary = await _analyticsService.getDailySummary(formattedDate);
    final logs = await _analyticsService.getTemperatureLogs(formattedDate);

    setState(() {
      _dailySummary = summary;
      _logs = logs;
    });

    _checkEthyleneLevels();
  }

  void _checkEthyleneLevels() {
    if (_dailySummary['maxEthylene'] != null && _dailySummary['maxEthylene'] > ethyleneThreshold) {
      _showWarningDialog();
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Text("High levels of ethylene detected!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      _fetchDailySummary();
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
              _buildLogsTable(),
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
          _buildGauge('Temperature', _dailySummary['averageTemperature'] ?? 0.0, 100, const Color.fromARGB(255, 129, 179, 255), true),
          _buildGauge('Ethylene', _dailySummary['averageEthylene'] ?? 0.0, 10, Colors.green, false),
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
          _buildSummaryRow('Max Temperature', 
            '${_dailySummary['maxTemperature']?.toStringAsFixed(1) ?? '0.0'}°F'),
          _buildSummaryRow('Min Temperature', 
            '${_dailySummary['minTemperature']?.toStringAsFixed(1) ?? '0.0'}°F'),
          _buildSummaryRow('Max Ethylene', 
            '${_dailySummary['maxEthylene']?.toStringAsFixed(1) ?? '0.0'} ppm'),
          _buildSummaryRow('Min Ethylene', 
            '${_dailySummary['minEthylene']?.toStringAsFixed(1) ?? '0.0'} ppm'),
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

  Widget _buildGauge(String label, double value, double maxValue, Color color, bool isTemperature) {
    return Container(
      width: double.infinity,  // Make the gauge container take the full width
      height: 200, // Adjust the height to fit the gauge properly
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

  Widget _buildLogsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Detailed Logs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _logs.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No logs available for this date',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.grey[800]!
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Time',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Temperature',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Ethylene',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  rows: _logs.map((log) {
                    return DataRow(
                      cells: [
                        DataCell(Text(
                          log['time'] ?? 'N/A', 
                          style: TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          '${log['temperature']?.toStringAsFixed(1) ?? 'N/A'}°F', 
                          style: TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          log['ethylene']?.toStringAsFixed(1) ?? 'N/A', 
                          style: TextStyle(color: Colors.white),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
        ],
      ),
    );
  }
}