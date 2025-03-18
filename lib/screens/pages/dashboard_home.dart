import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("لوحة التحكم", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _buildStats(),
          ),
          const SizedBox(height: 20),
          _buildBarChart(),
          const SizedBox(height: 20),
          _buildPieChart(),
        ],
      ),
    );
  }

  List<Widget> _buildStats() {
    return [
      _buildStatCard("الرحلات اليوم", "120", LucideIcons.map),
      _buildStatCard("السائقون المتاحون", "45", LucideIcons.userCheck),
      _buildStatCard("المستخدمون الجدد", "85", LucideIcons.users),
      _buildStatCard("الإيرادات (اليوم)", "\$4,500", LucideIcons.dollarSign),
    ];
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.yellow.shade600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.black),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black, fontSize: 14)),
                Text(value, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("عدد الرحلات خلال الأسبوع", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < 7; i++)
                      BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 3) * 10, color: Colors.yellow.shade700)])
                  ],
                  titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: _bottomTitles())),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SideTitles _bottomTitles() {
    return SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        const days = ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(days[value.toInt()], style: const TextStyle(fontSize: 12)),
        );
      },
    );
  }

  Widget _buildPieChart() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("نسبة السائقين النشطين", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 70, title: "نشطين", color: Colors.green, radius: 50),
                    PieChartSectionData(value: 30, title: "غير نشطين", color: Colors.red, radius: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}