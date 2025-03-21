import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'User/user_home.dart';
import 'User/mytrip.dart';
import 'User/payment_page.dart';
import 'User/offers_page.dart';
import 'User/settings_page.dart';
import 'User/support_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const UserDashboard(),
//     );
//   }
// }

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MyTripsPage(),
    const PaymentPage(),
    const OffersPage(),
    const SettingsPage(),
    const SupportPage(),
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
              title: const Text("TaxiGo 🚖"),
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
                BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "الرئيسية"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: "رحلاتي"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.creditCard), label: "الدفع"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.tag), label: "العروض"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.settings), label: "الإعدادات"),
                BottomNavigationBarItem(icon: Icon(LucideIcons.helpCircle), label: "الدعم"),
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
          const Icon(LucideIcons.user, size: 60, color: Colors.black),
          const SizedBox(height: 10),
          const Text("مرحباً، أحمد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.black),
          _buildSidebarItem("الرئيسية", LucideIcons.home, 0),
          _buildSidebarItem("رحلاتي", LucideIcons.map, 1),
          _buildSidebarItem("الدفع", LucideIcons.creditCard, 2),
          _buildSidebarItem("العروض", LucideIcons.tag, 3),
          _buildSidebarItem("الإعدادات", LucideIcons.settings, 4),
          _buildSidebarItem("الدعم", LucideIcons.helpCircle, 5),
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
