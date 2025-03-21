import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.yellow.shade700,
              title: const Text("⚙ الإعدادات والخصوصية"),
            ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600), // ضبط العرض للويب
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text("⚙ الإعدادات والخصوصية", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // 🔹 الحساب والمعلومات الشخصية
              _buildSettingsSection("👤 الحساب والمعلومات الشخصية", [
                _buildSettingsItem("تعديل الملف الشخصي", LucideIcons.user, () {}),
                _buildSettingsItem("تغيير كلمة المرور", LucideIcons.lock, () {}),
                _buildSettingsItem("إدارة العناوين", LucideIcons.mapPin, () {}),
              ]),

              // 🔐 إعدادات الأمان والخصوصية
              _buildSettingsSection("🔐 الأمان والخصوصية", [
                _buildSettingsItem("المصادقة الثنائية", LucideIcons.shieldCheck, () {}),
                _buildSettingsItem("إدارة الأذونات", LucideIcons.shieldAlert, () {}),
                _buildSettingsItem("عرض سجل النشاطات", LucideIcons.fileSearch, () {}),
              ]),

              // 💳 إعدادات الدفع والفوترة
              _buildSettingsSection("💳 الدفع والفوترة", [
                _buildSettingsItem("إدارة بطاقات الدفع", LucideIcons.creditCard, () {}),
                _buildSettingsItem("عرض الفواتير والمدفوعات", LucideIcons.receipt, () {}),
                _buildSettingsItem("إعدادات الدفع التلقائي", LucideIcons.wallet, () {}),
              ]),

              // 🔔 إعدادات الإشعارات
              _buildSettingsSection("🔔 إعدادات الإشعارات", [
                _buildSettingsItem("إشعارات الرحلات", LucideIcons.bell, () {}),
                _buildSettingsItem("إشعارات العروض والتخفيضات", LucideIcons.gift, () {}),
                _buildSettingsItem("إشعارات الأمان والطوارئ", LucideIcons.alertTriangle, () {}),
              ]),

              // 🎨 إعدادات المظهر والتطبيق
              _buildSettingsSection("🎨 إعدادات التطبيق", [
              
                _buildSettingsItem("الوضع الليلي", LucideIcons.moon, () {}),
                _buildSettingsItem("تغيير اللغة", LucideIcons.globe, () {}),
                _buildSettingsItem("إدارة حجم الخط والمظهر", LucideIcons.text, () {}),
              ]),

              // 🚪 تسجيل الخروج
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.logOut, color: Colors.white),
                label: const Text("تسجيل الخروج", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ أداة لإنشاء قسم الإعدادات
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...items,
        const Divider(thickness: 1, height: 30),
      ],
    );
  }

  /// ✅ أداة لإنشاء عنصر إعدادات فردي
  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow.shade700),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

