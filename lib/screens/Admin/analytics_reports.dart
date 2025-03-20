import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsReportsPage extends StatelessWidget {
  const AnalyticsReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text("التقارير والتحليلات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("إحصائيات الرحلات"),
            _buildTripsChart(),
            const SizedBox(height: 20),
            _buildSectionTitle("نسبة السائقين النشطين"),
            _buildActiveDriversPieChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTripsChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (int i = 1; i <= 7; i++)
              BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i * 10).toDouble(), color: Colors.blue)])
          ],
          titlesData: FlTitlesData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildActiveDriversPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 70, title: 'نشط', color: Colors.green, radius: 50),
            PieChartSectionData(value: 30, title: 'غير نشط', color: Colors.red, radius: 50),
          ],
        ),
      ),
    );
  }
}