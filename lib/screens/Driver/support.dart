import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade700,
        title: const Text("الدعم الفني"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("تواصل مع الدعم"),
            _buildSupportOptions(),
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

  Widget _buildSupportOptions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(LucideIcons.headphones, color: Colors.blue),
          title: const Text("الدعم عبر الهاتف"),
          subtitle: const Text("اتصل بنا على: 0123456789"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(LucideIcons.mail, color: Colors.blue),
          title: const Text("الدعم عبر البريد الإلكتروني"),
          subtitle: const Text("support@taxigo.com"),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(LucideIcons.messageCircle, color: Colors.blue),
          title: const Text("الدعم عبر الدردشة"),
          subtitle: const Text("تواصل معنا مباشرة عبر الدردشة"),
          onTap: () {},
        ),
      ],
    );
  }
}
