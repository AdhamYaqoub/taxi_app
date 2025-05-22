import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

import 'Admin/dashboard_home.dart';
import 'Admin/drivers_page.dart';
import 'Admin/users_page.dart';
import 'Admin/settings_page.dart';
import 'Admin/trips_management.dart';
import 'Admin/payments_management.dart';
import 'Admin/security_monitoring.dart';
import 'Admin/analytics_reports.dart';
import 'Admin/vip_corporate.dart';

class AdminDashboard extends StatefulWidget {
  final String userId;
  final String token;

  const AdminDashboard({super.key, required this.userId, required this.token});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  String? fullName;
  bool isLoadingName = true;

  @override
  void initState() {
    super.initState();
    fetchFullName();
    _pages = [
      const DashboardHome(),
      const DriversPage(),
      const UsersPage(),
      const DriverTripsPage(),
      const PaymentsManagementPage(),
      const SecurityMonitoringPage(),
      const AnalyticsReportsPage(),
      const VipCorporatePage(),
      SettingsPage(
        userId: widget.userId,
        token: widget.token,
      ),
    ];
  }

  Future<void> fetchFullName() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/users/fullname/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          fullName = data['fullName'];
          isLoadingName = false;
        });
      } else {
        throw Exception('Failed to load name');
      }
    } catch (e) {
      print('Error fetching name: $e');
      setState(() {
        isLoadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).translate('admin_dashboard')),
                  if (!isLoadingName && fullName != null)
                    Text(
                      fullName!,
                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                ],
              ),
            ),
      drawer: isWeb ? null : Drawer(child: _buildSidebarContent(theme)),
      body: Row(
        children: [
          if (isWeb) _buildSidebarContent(theme),
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
              selectedItemColor: theme.colorScheme.onPrimary,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
              backgroundColor: theme.colorScheme.primary,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.layoutDashboard),
                    label: AppLocalizations.of(context).translate('home')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.userCheck),
                    label: AppLocalizations.of(context).translate('drivers')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.users),
                    label: AppLocalizations.of(context).translate('users')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.car),
                    label: AppLocalizations.of(context).translate('trips_management')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.dollarSign),
                    label: AppLocalizations.of(context).translate('payments_management')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.shieldCheck),
                    label: AppLocalizations.of(context).translate('security_monitoring')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.barChart),
                    label: AppLocalizations.of(context).translate('analytics_reports')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.star),
                    label: AppLocalizations.of(context).translate('vip_corporate')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.settings),
                    label: AppLocalizations.of(context).translate('settings')),
              ],
            ),
    );
  }

  Widget _buildSidebarContent(ThemeData theme) {
    return Container(
      width: 250,
      color: theme.colorScheme.primary,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(LucideIcons.car, size: 60, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 10),
          Text("TaxiGo Admin",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary)),
          if (!isLoadingName && fullName != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                fullName!,
                style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),
              ),
            ),
          Divider(color: theme.colorScheme.onPrimary),
          _buildSidebarItem(AppLocalizations.of(context).translate('home'),
              LucideIcons.layoutDashboard, 0, theme),
          _buildSidebarItem(AppLocalizations.of(context).translate('drivers'),
              LucideIcons.userCheck, 1, theme),
          _buildSidebarItem(AppLocalizations.of(context).translate('users'),
              LucideIcons.users, 2, theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('trips_management'),
              LucideIcons.car,
              3,
              theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('payments_management'),
              LucideIcons.dollarSign,
              4,
              theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('security_monitoring'),
              LucideIcons.shieldCheck,
              5,
              theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('analytics_reports'),
              LucideIcons.barChart,
              6,
              theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('vip_corporate'),
              LucideIcons.star,
              7,
              theme),
          _buildSidebarItem(AppLocalizations.of(context).translate('settings'),
              LucideIcons.settings, 8, theme),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      String title, IconData icon, int index, ThemeData theme) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onPrimary),
      title: Text(title, style: TextStyle(color: theme.colorScheme.onPrimary)),
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
