import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PaymentsManagementPage extends StatelessWidget {
  const PaymentsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text("إدارة المدفوعات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("تفاصيل المعاملات"),
            _buildTransactionList(),
            const SizedBox(height: 20),
            _buildSectionTitle("إدارة الأسعار والعروض"),
            _buildPricingControls(),
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

  Widget _buildTransactionList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                index.isEven ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
                color: index.isEven ? Colors.green : Colors.red,
              ),
              title: Text("معاملة #${index + 1}"),
              subtitle: Text(index.isEven ? "تمت بنجاح" : "فشل الدفع"),
              trailing: IconButton(
                icon: const Icon(LucideIcons.eye),
                onPressed: () {
                  // وظيفة عرض تفاصيل المعاملة
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPricingControls() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(LucideIcons.dollarSign, color: Colors.black),
          title: const Text("تعديل أسعار الرحلات"),
          trailing: IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              // وظيفة تعديل الأسعار
            },
          ),
        ),
        ListTile(
          leading: const Icon(LucideIcons.percent, color: Colors.black),
          title: const Text("إدارة العروض والخصومات"),
          trailing: IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              // وظيفة إدارة العروض
            },
          ),
        ),
      ],
    );
  }
}