import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SecurityMonitoringPage extends StatelessWidget {
  const SecurityMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        title: const Text("مراقبة الأمان"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("تنبيهات الطوارئ"),
            _buildEmergencyAlerts(),
            const SizedBox(height: 20),
            _buildSectionTitle("مراقبة الرحلات المشبوهة"),
            _buildSuspiciousTripsList(),
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

  Widget _buildEmergencyAlerts() {
    return Card(
      color: Colors.red.shade100,
      child: ListTile(
        leading: const Icon(LucideIcons.alertCircle, color: Colors.red),
        title: const Text("زر SOS مفعل من سائق"),
        subtitle: const Text("سائق: أحمد - الموقع الحالي: شارع الملك فهد"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            // استدعاء الطوارئ
          },
          child: const Text("اتخاذ إجراء"),
        ),
      ),
    );
  }

  Widget _buildSuspiciousTripsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(LucideIcons.zap, color: Colors.orange),
              title: Text("رحلة مشبوهة #${index + 1}"),
              subtitle: const Text("تم اكتشاف تغيير مسار مفاجئ"),
              trailing: IconButton(
                icon: const Icon(LucideIcons.eye),
                onPressed: () {
                  // عرض التفاصيل
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
