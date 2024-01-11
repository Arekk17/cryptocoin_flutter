import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CryptoDetailPage extends StatelessWidget {
  final Map<String, dynamic> crypto;

  CryptoDetailPage({required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crypto['name']),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Price: ${crypto['current_price']}'),
            subtitle:
                Text('24h Change: ${crypto['price_change_percentage_24h']}%'),
          ),
          Expanded(
            child: LineChart(sampleData1()),
          ),
        ],
      ),
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 1),
            FlSpot(1, 3),
            FlSpot(10, 20),
            // Add more spots here
          ],
          isCurved: true,
          color: Colors.blue, // Corrected property for color
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
        ),
      ],
      // Additional properties for LineChartData can be added here
    );
  }
}
