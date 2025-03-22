import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'Driver/driver_home.dart';
import 'Driver/driver_trips.dart';
import 'Driver/earnings.dart';
import 'Driver/driver_settings.dart';
import 'Driver/support.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const DriverDashboard(),
//     );
//   }
// }

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DriverHomePage(),
    const DriverTripsPage(driverName: '', trips: [],),
    const EarningsPage(),
    const SupportPage(),
    const DriverSettingsPage(),
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
              title: const Text("لوحة السائق"),
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
              items: [
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.home), label: "الرئيسية"),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.car), label: "رحلاتي"),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.dollarSign), label: "الأرباح"),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.headphones), label: "الدعم"),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.settings), label: "الإعدادات"),
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
          Icon(LucideIcons.car, size: 60, color: Colors.white),
          const SizedBox(height: 10),
          const Text("TaxiGo Driver",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const Divider(color: Colors.white),
          _buildSidebarItem("الرئيسية", LucideIcons.home, 0),
          _buildSidebarItem("رحلاتي", LucideIcons.car, 1),
          _buildSidebarItem("الأرباح", LucideIcons.dollarSign, 2),
          _buildSidebarItem("الدعم", LucideIcons.headphones, 3),
          _buildSidebarItem("الإعدادات", LucideIcons.settings, 4),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
