// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CryptoDetailPage extends StatelessWidget {
  final Map<String, dynamic> crypto;
  final List<dynamic> historicalData;

  CryptoDetailPage(
      {Key? key, required this.crypto, required this.historicalData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final spots = historicalData.asMap().entries.map<FlSpot>((entry) {
      double x = entry.key.toDouble();
      double y = entry.value[1];
      return FlSpot(x, y);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(crypto['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                title: Text('Cena: \$${crypto['current_price']}'),
                subtitle: Text(
                    'Zmiana w 24h: ${crypto['price_change_percentage_24h']}%'),
              ),
              _buildDetailItem('Kapitalizacja rynkowa', crypto['market_cap']),
              _buildDetailItem('Wolumen (24h)', crypto['total_volume']),
              _buildDetailItem('Podaż', crypto['circulating_supply']),
              _buildDetailItem('Ranking rynkowy', crypto['market_cap_rank']),
              SizedBox(height: 30),
              AspectRatio(
                aspectRatio: 1.3,
                child: LineChart(sampleData1(spots)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, dynamic value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value != null ? value.toString() : 'N/A'),
    );
  }

  LineChartData sampleData1(List<FlSpot> spots) {
    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }
}
