import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text("الأرباح"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("إجمالي الأرباح"),
            _buildEarningsSummary(),
            const SizedBox(height: 20),
            _buildSectionTitle("تفاصيل الأرباح"),
            _buildEarningsDetails(),
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

  Widget _buildEarningsSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("إجمالي الأرباح:", style: TextStyle(fontSize: 16)),
            Text("\$1,200",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsDetails() {
    return Expanded(
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(LucideIcons.dollarSign, color: Colors.blue),
              title: Text("رحلة #${index + 1}"),
              subtitle: Text("التاريخ: 2023-10-${index + 1}"),
              trailing: Text("\$${(index + 1) * 20}"),
            ),
          );
        },
      ),
    );
  }
}
