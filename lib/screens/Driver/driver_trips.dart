import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DriverTripsPage extends StatelessWidget {
  const DriverTripsPage({super.key, required String driverName, required List<Map<String, String>> trips});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text("رحلاتي"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("رحلات اليوم"),
            _buildTripList(),
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

  Widget _buildTripList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(LucideIcons.car, color: Colors.blue),
              title: Text("رحلة #${index + 1}"),
              subtitle: Text("المسافة: ${(index + 1) * 5} كم"),
              trailing: Text("\$${(index + 1) * 10}"),
            ),
          );
        },
      ),
    );
  }
}
