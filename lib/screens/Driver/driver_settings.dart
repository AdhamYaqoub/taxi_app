import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DriverSettingsPage extends StatefulWidget {
  const DriverSettingsPage({super.key});

  @override
  _DriverSettingsPageState createState() => _DriverSettingsPageState();
}

class _DriverSettingsPageState extends State<DriverSettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("إعدادات السائق ⚙"),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("إعدادات الحساب"),
          _buildSettingsItem(
            icon: LucideIcons.user,
            title: "تعديل الملف الشخصي",
            subtitle: "تعديل معلومات الحساب",
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: LucideIcons.bell,
            title: "الإشعارات",
            subtitle: "التحكم في التنبيهات",
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
              activeColor: Colors.green,
            ),
          ),
          _buildSettingsItem(
            icon: LucideIcons.moon,
            title: "الوضع الليلي",
            subtitle: "تفعيل أو تعطيل الوضع الداكن",
            trailing: Switch(
              value: darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  darkModeEnabled = value;
                });
              },
              activeColor: Colors.black,
            ),
          ),
          _buildSectionTitle("الأمان"),
          _buildSettingsItem(
            icon: LucideIcons.shieldCheck,
            title: "إدارة الأمان",
            subtitle: "إعدادات الأمان وحماية الحساب",
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: LucideIcons.key,
            title: "تغيير كلمة المرور",
            subtitle: "إعادة تعيين كلمة المرور الخاصة بك",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
