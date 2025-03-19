import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TripsManagementPage extends StatelessWidget {
  const TripsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text("إدارة الرحلات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("الرحلات الجارية"),
            _buildTripList(),
            const SizedBox(height: 20),
            _buildSectionTitle("الرحلات المنتهية"),
            _buildTripList(isOngoing: false),
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

  Widget _buildTripList({bool isOngoing = true}) {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                isOngoing ? LucideIcons.car : LucideIcons.checkCircle,
                color: isOngoing ? Colors.blue : Colors.green,
              ),
              title: Text("رحلة #${index + 1}"),
              subtitle: Text(
                isOngoing ? "في تقدم - السائق: أحمد" : "مكتملة - السائق: خالد",
              ),
              trailing: isOngoing
                  ? IconButton(
                      icon: const Icon(LucideIcons.xCircle, color: Colors.red),
                      onPressed: () {
                        // وظيفة إلغاء الرحلة
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}