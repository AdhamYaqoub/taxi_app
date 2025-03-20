import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VipCorporatePage extends StatelessWidget {
  const VipCorporatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade700,
        title: const Text("إدارة العملاء VIP والشركات"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("حسابات الشركات"),
            _buildCompanyManagementCard(),
            const SizedBox(height: 20),
            _buildSectionTitle("خدمات VIP"),
            _buildVipManagementCard(),
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

  Widget _buildCompanyManagementCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(LucideIcons.building, color: Colors.blue),
        title: const Text("إدارة حسابات الشركات"),
        subtitle: const Text("إنشاء وتعديل ومتابعة حسابات الشركات المتعاقدة"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }

  Widget _buildVipManagementCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(LucideIcons.star, color: Colors.amber),
        title: const Text("إدارة خدمات VIP"),
        subtitle: const Text("منح امتيازات خاصة للعملاء المميزين ومتابعة حساباتهم"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}