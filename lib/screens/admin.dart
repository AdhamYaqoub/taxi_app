import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/screens/Admin/analytics_reports.dart';
import 'package:taxi_app/screens/Admin/dashboard_home.dart';
import 'package:taxi_app/screens/Admin/drivers_page.dart';
import 'package:taxi_app/screens/Admin/payments_management.dart';
import 'package:taxi_app/screens/Admin/security_monitoring.dart';
import 'package:taxi_app/screens/Admin/settings_page.dart';
import 'package:taxi_app/screens/Admin/trips_management.dart';
import 'package:taxi_app/screens/Admin/users_page.dart';
import 'package:taxi_app/screens/Admin/vip_corporate.dart';

class AdminDashboard extends StatefulWidget {
  final int userId;
  final String token;

  const AdminDashboard({super.key, required this.userId, required this.token});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  String? _fullName;
  bool _isLoading = true;
  bool _accessGranted = false;

  @override
  void initState() {
    super.initState();
    _pages = _initializePages();
    _verifyAndLoadData();
  }

  List<Widget> _initializePages() {
    return [
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

  Future<void> _verifyAndLoadData() async {
    try {
      // التحقق من الصلاحيات أولاً
      final accessResponse = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/users/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (accessResponse.statusCode != 200) {
        _handleAccessDenied();
        return;
      }

      final userData = jsonDecode(accessResponse.body);
      if (userData['user']?['role'] != 'Admin' ||
          userData['user']?['isLoggedIn'] != true) {
        _handleAccessDenied();
        return;
      }

      // جلب البيانات إذا التحقق ناجح
      await _loadUserData();

      setState(() {
        _accessGranted = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error during verification: $e');
      _handleAccessDenied();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/api/users/fullname/${widget.userId}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _fullName = jsonDecode(response.body)['fullName'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _handleAccessDenied() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('access_denied')),
        content: Text(AppLocalizations.of(context).translate('no_permission')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // إغلاق الـ AlertDialog
              Navigator.of(context).popUntil(
                  (route) => route.isFirst); // العودة إلى الشاشة الأولى
            },
            child: Text(AppLocalizations.of(context).translate('ok')),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('verifying_access'),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_accessGranted || _isLoading) {
      return _buildLoadingScreen();
    }

    final theme = Theme.of(context);
    final bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isWeb ? null : _buildMobileAppBar(theme),
      drawer: isWeb ? null : _buildMobileDrawer(theme),
      body: Row(
        children: [
          if (isWeb) _buildDesktopSidebar(theme),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isWeb ? null : _buildMobileBottomNav(theme),
    );
  }

  AppBar _buildMobileAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('admin_dashboard')),
          if (_fullName != null)
            Text(
              _fullName!,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(ThemeData theme) {
    return Drawer(
      child: _buildSidebarContent(theme),
    );
  }

  Widget _buildDesktopSidebar(ThemeData theme) {
    return Container(
      width: 250,
      color: theme.colorScheme.primary,
      child: _buildSidebarContent(theme),
    );
  }

  Widget _buildSidebarContent(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(LucideIcons.car, size: 60, color: theme.colorScheme.onPrimary),
        const SizedBox(height: 10),
        Text(
          "TaxiGo Admin",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        if (_fullName != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _fullName!,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 14,
              ),
            ),
          ),
        Divider(color: theme.colorScheme.onPrimary),
        ..._buildSidebarItems(theme),
      ],
    );
  }

  List<Widget> _buildSidebarItems(ThemeData theme) {
    final local = AppLocalizations.of(context);
    return [
      _buildSidebarItem(
          local.translate('home'), LucideIcons.layoutDashboard, 0, theme),
      _buildSidebarItem(
          local.translate('drivers'), LucideIcons.userCheck, 1, theme),
      _buildSidebarItem(local.translate('users'), LucideIcons.users, 2, theme),
      _buildSidebarItem(
          local.translate('trips_management'), LucideIcons.car, 3, theme),
      _buildSidebarItem(local.translate('payments_management'),
          LucideIcons.dollarSign, 4, theme),
      _buildSidebarItem(local.translate('security_monitoring'),
          LucideIcons.shieldCheck, 5, theme),
      _buildSidebarItem(
          local.translate('analytics_reports'), LucideIcons.barChart, 6, theme),
      _buildSidebarItem(
          local.translate('vip_corporate'), LucideIcons.star, 7, theme),
      _buildSidebarItem(
          local.translate('settings'), LucideIcons.settings, 8, theme),
    ];
  }

  Widget _buildSidebarItem(
      String title, IconData icon, int index, ThemeData theme) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onPrimary),
      title: Text(title, style: TextStyle(color: theme.colorScheme.onPrimary)),
      selected: _selectedIndex == index,
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  BottomNavigationBar _buildMobileBottomNav(ThemeData theme) {
    final local = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: theme.colorScheme.onPrimary,
      unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
      backgroundColor: theme.colorScheme.primary,
      items: [
        _buildNavItem(LucideIcons.layoutDashboard, local.translate('home')),
        _buildNavItem(LucideIcons.userCheck, local.translate('drivers')),
        _buildNavItem(LucideIcons.users, local.translate('users')),
        _buildNavItem(LucideIcons.car, local.translate('trips_management')),
        _buildNavItem(
            LucideIcons.dollarSign, local.translate('payments_management')),
        _buildNavItem(
            LucideIcons.shieldCheck, local.translate('security_monitoring')),
        _buildNavItem(
            LucideIcons.barChart, local.translate('analytics_reports')),
        _buildNavItem(LucideIcons.star, local.translate('vip_corporate')),
        _buildNavItem(LucideIcons.settings, local.translate('settings')),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}
