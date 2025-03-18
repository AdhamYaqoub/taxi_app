import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'pages/dashboard_home.dart';
import 'pages/drivers_page.dart';
import 'pages/users_page.dart';
import 'pages/settings_page.dart';
import 'pages/trips_management.dart';
import 'pages/payments_management.dart';
import 'pages/security_monitoring.dart';
import 'pages/analytics_reports.dart';
import 'pages/vip_corporate.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const AdminDashboard(),
//     );
//   }
// }

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const DriversPage(),
    const UsersPage(),
    const TripsManagementPage(),
    const PaymentsManagementPage(),
    const SecurityMonitoringPage(),
    const AnalyticsReportsPage(),
    const VipCorporatePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: Colors.yellow.shade700,
              title: const Text("لوحة الأدمن"),
            ),
      drawer: isWeb ? null : Drawer(child: _buildSidebarContent()),
      body: Row(
        children: [
          if (isWeb) _buildSidebarContent(),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isWeb
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.yellow.shade700,
              items: const [
                BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: "الرئيسية"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.userCheck), label: "السائقين"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: "المستخدمين"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.car), label: "إدارة الرحلات"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.dollarSign), label: "المدفوعات"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.shieldCheck), label: "الأمان"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.barChart), label: "التقارير"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.star), label: "VIP & الشركات"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: "الإعدادات"),
              ],
            ),
    );
  }

  Widget _buildSidebarContent() {
    return Container(
      width: 250,
      color: Colors.yellow.shade700,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(LucideIcons.car, size: 60, color: Colors.black),
          const SizedBox(height: 10),
          const Text("TaxiGo Admin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.black),
          _buildSidebarItem("الرئيسية", LucideIcons.layoutDashboard, 0),
          _buildSidebarItem("السائقين", LucideIcons.userCheck, 1),
          _buildSidebarItem("المستخدمين", LucideIcons.users, 2),
          _buildSidebarItem("إدارة الرحلات", LucideIcons.car, 3),
          _buildSidebarItem("المدفوعات", LucideIcons.dollarSign, 4),
          _buildSidebarItem("الأمان", LucideIcons.shieldCheck, 5),
          _buildSidebarItem("التقارير", LucideIcons.barChart, 6),
          _buildSidebarItem("VIP & الشركات", LucideIcons.star, 7),
          _buildSidebarItem("الإعدادات", LucideIcons.settings, 8),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
