import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("لوحة السائق",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _buildStats(),
          ),
          const SizedBox(height: 20),
          _buildRecentTrips(),
        ],
      ),
    );
  }

  List<Widget> _buildStats() {
    return [
      _buildStatCard("الرحلات اليوم", "12", LucideIcons.car),
      _buildStatCard("الأرباح اليوم", "\$150", LucideIcons.dollarSign),
      _buildStatCard("التقييمات", "4.8", LucideIcons.star),
      _buildStatCard("الساعات النشطة", "8h", LucideIcons.clock),
    ];
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.yellow.shade700,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrips() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("آخر الرحلات",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(LucideIcons.car, color: Colors.blue),
                  title: Text("رحلة #${index + 1}"),
                  subtitle: Text("المسافة: ${(index + 1) * 5} كم"),
                  trailing: Text("\$${(index + 1) * 10}"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
