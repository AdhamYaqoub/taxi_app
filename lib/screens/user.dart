import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/screens/User/drivers_list_page.dart';
import 'package:taxi_app/screens/components/NotificationIcon.dart';
import 'User/user_home.dart';
import 'User/mytrip.dart';
import 'User/payment_page.dart';
import 'User/offers_page.dart';
import 'User/settings_page.dart';
import 'User/support_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserDashboard extends StatefulWidget {
  final int userId;

  const UserDashboard({super.key, required this.userId});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

 late List<Widget> _pages;

@override
void initState() {
  super.initState();
  _pages = [
    HomePage(userId: widget.userId),
    ClientTripsPage(userId: widget.userId),
    const DriversListPage(),
    const PaymentPage(),
    const SettingsPage(),
    const SupportPage(),
    const OffersPage(),
  ];
}



  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          AppLocalizations.of(context).translate('user_dashboard'),
          style: TextStyle(
            fontSize: kIsWeb ? 24 : 18, // أكبر شوي للويب
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (kIsWeb) ...[
            NotificationIcon(userId: widget.userId),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // فتح صفحة إعدادات خاصة بالويب مثلاً
              },
            ),
          ] else ...[
            NotificationIcon(userId:widget.userId),
            const SizedBox(width: 8),
          ],
        ],
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
                    icon: Icon(LucideIcons.home),
                    label: AppLocalizations.of(context).translate('home')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.history),
                    label: AppLocalizations.of(context)
                        .translate('trips_history')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.list),
                    label:
                        AppLocalizations.of(context).translate('drivers_list')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.creditCard),
                    label: AppLocalizations.of(context)
                        .translate('payment_methods')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.settings),
                    label: AppLocalizations.of(context).translate('settings')),
                BottomNavigationBarItem(
                    icon: Icon(LucideIcons.helpCircle),
                    label: AppLocalizations.of(context).translate('support')),
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
          Text("TaxiGo User",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary)),
          Divider(color: theme.colorScheme.onPrimary),
          _buildSidebarItem(AppLocalizations.of(context).translate('home'),
              LucideIcons.home, 0, theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('trips_history'),
              LucideIcons.history,
              1,
              theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('drivers_list'),
              LucideIcons.list,
              2,
              theme),
          _buildSidebarItem(
              AppLocalizations.of(context).translate('payment_methods'),
              LucideIcons.creditCard,
              3,
              theme),
          _buildSidebarItem(AppLocalizations.of(context).translate('settings'),
              LucideIcons.settings, 4, theme),
          _buildSidebarItem(AppLocalizations.of(context).translate('support'),
              LucideIcons.helpCircle, 5, theme),
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
        _navigateToPage(index);
      },
    );
  }
}
