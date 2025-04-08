import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart'; // إضافة الترجمة
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  _DashboardHomeState createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool isLoading = true;
  int todayTrips = 0;
  int availableDrivers = 0;
  int newUsers = 0;
  double revenueToday = 0.0;
  List<int> weeklyTrips = [0, 0, 0, 0, 0, 0, 0]; // بيانات افتراضية
  double activeDriversPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  // جلب بيانات لوحة القيادة من API
Future<void> fetchDashboardData() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:5000/api/dashboard')); // استخدم 10.0.2.2 في محاكي Android
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      setState(() {
        todayTrips = data['todayTrips'] ?? 0;
        availableDrivers = data['availableDrivers'] ?? 0;
        newUsers = data['newUsers'] ?? 0;
        revenueToday = data['revenueToday']?.toDouble() ?? 0.0;
        
        // تحقق إذا كانت weeklyTrips تحتوي على بيانات قبل استخدامها
        if (data['weeklyTrips'] != null && data['weeklyTrips'].length == 7) {
          weeklyTrips = List<int>.from(data['weeklyTrips']);
        } else {
          weeklyTrips = [0, 0, 0, 0, 0, 0, 0]; // بيانات افتراضية إذا كانت فارغة
        }
        
        activeDriversPercentage = data['activeDriversPercentage']?.toDouble() ?? 0.0;
        isLoading = false;
      });
    } else {
      throw Exception('فشل في جلب بيانات لوحة القيادة');
    }
  } catch (error) {
    setState(() {
      isLoading = false;
    });
    print("Error: $error");
  }
}


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator()) // عند تحميل البيانات
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('dashboard'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _buildStats(context),
                ),
                const SizedBox(height: 20),
                _buildBarChart(context),
                const SizedBox(height: 20),
                _buildPieChart(context),
              ],
            ),
          );
  }

  // بناء بطاقات الإحصائيات
  List<Widget> _buildStats(BuildContext context) {
    return [
      _buildStatCard(
        AppLocalizations.of(context).translate('todayTrips'),
        "$todayTrips",
        LucideIcons.map,
      ),
      _buildStatCard(
        AppLocalizations.of(context).translate('availableDrivers'),
        "$availableDrivers",
        LucideIcons.userCheck,
      ),
      _buildStatCard(
        AppLocalizations.of(context).translate('newUsers'),
        "$newUsers",
        LucideIcons.users,
      ),
      _buildStatCard(
        AppLocalizations.of(context).translate('revenueToday'),
        "\$${revenueToday.toStringAsFixed(2)}",
        LucideIcons.dollarSign,
      ),
    ];
  }

  // بناء بطاقة الإحصائيات
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

  // بناء الرسم البياني الشريطي
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
              AppLocalizations.of(context).translate('weeklyTrips'),
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
                        BarChartRodData(toY: (weeklyTrips[i] + 3) * 10, color: Colors.yellow.shade700)
                      ])
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

  // تخصيص العناوين السفلية للرسم البياني
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

  // بناء الرسم البياني الدائري
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
              AppLocalizations.of(context).translate('activeDriversPercentage'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: activeDriversPercentage,
                      title: AppLocalizations.of(context).translate('active'),
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: 100 - activeDriversPercentage,
                      title: AppLocalizations.of(context).translate('inactive'),
                      color: Colors.red,
                      radius: 40,
                    ),
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
