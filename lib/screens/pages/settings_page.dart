import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("الإعدادات ⚙"),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("إعدادات التطبيق"),
          _buildSettingsItem(
            icon: LucideIcons.sliders,
            title: "إدارة النظام",
            subtitle: "تعديل إعدادات الخدمة والمناطق",
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
          _buildSectionTitle("الأمان والخصوصية"),
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
          _buildSectionTitle("التحديثات والدعم"),
          _buildSettingsItem(
            icon: LucideIcons.refreshCcw,
            title: "التحقق من التحديثات",
            subtitle: "تحديث التطبيق إلى آخر إصدار",
            onTap: () {},
          ),
          _buildSettingsItem(
            icon: LucideIcons.helpCircle,
            title: "الدعم الفني",
            subtitle: "تواصل مع فريق الدعم",
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
