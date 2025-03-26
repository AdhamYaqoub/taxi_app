import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart'; // إضافة الترجمة

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)
                .translate('dashboard'), // استخدام الترجمة
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _buildStats(context), // تمرير context للترجمة
          ),
          const SizedBox(height: 20),
          _buildBarChart(context),
          const SizedBox(height: 20),
          _buildPieChart(context),
        ],
      ),
    );
  }

  List<Widget> _buildStats(BuildContext context) {
    return [
      _buildStatCard(AppLocalizations.of(context).translate('todayTrips'),
          "120", LucideIcons.map),
      _buildStatCard(AppLocalizations.of(context).translate('availableDrivers'),
          "45", LucideIcons.userCheck),
      _buildStatCard(AppLocalizations.of(context).translate('newUsers'), "85",
          LucideIcons.users),
      _buildStatCard(AppLocalizations.of(context).translate('revenueToday'),
          "\$4,500", LucideIcons.dollarSign),
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
                Text(title,
                    style: const TextStyle(color: Colors.black, fontSize: 14)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)
                  .translate('weeklyTrips'), // استخدام الترجمة
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < 7; i++)
                      BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                            toY: (i + 3) * 10, color: Colors.yellow.shade700)
                      ])
                  ],
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: _bottomTitles())),
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
        const days = [
          'سبت',
          'أحد',
          'إثنين',
          'ثلاثاء',
          'أربعاء',
          'خميس',
          'جمعة'
        ];
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child:
              Text(days[value.toInt()], style: const TextStyle(fontSize: 12)),
        );
      },
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)
                  .translate('activeDriversPercentage'), // استخدام الترجمة
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        value: 70,
                        title: AppLocalizations.of(context).translate('active'),
                        color: Colors.green,
                        radius: 50), // استخدام الترجمة
                    PieChartSectionData(
                        value: 30,
                        title:
                            AppLocalizations.of(context).translate('inactive'),
                        color: Colors.red,
                        radius: 40), // استخدام الترجمة
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
