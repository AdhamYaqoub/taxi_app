import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'Driver/driver_home.dart';
import 'Driver/driver_trips.dart';
import 'Driver/earnings.dart';
import 'Driver/driver_settings.dart';
import 'Driver/support.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DriverHomePage(),
    const DriverTripsPage(driverName: '', trips: []),
    const EarningsPage(),
    const SupportPage(),
    const DriverSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = MediaQuery.of(context).size.width > 800;
    final local = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text(
                local.translate('driver_dashboard'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
      drawer: isWeb ? null : Drawer(child: _buildMobileSidebar(theme, local)),
      body: Row(
        children: [
          if (isWeb) _buildDesktopSidebar(theme, local),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isWeb ? null : _buildBottomNavBar(theme, local),
    );
  }

  Widget _buildMobileSidebar(ThemeData theme, AppLocalizations local) {
    return Drawer(
      backgroundColor: theme.colorScheme.primary,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSidebarHeader(theme),
            _buildSidebarItem(
              local.translate('home'),
              LucideIcons.home,
              0,
              theme,
            ),
            _buildSidebarItem(
              local.translate('my_trips'),
              LucideIcons.car,
              1,
              theme,
            ),
            _buildSidebarItem(
              local.translate('earnings'),
              LucideIcons.dollarSign,
              2,
              theme,
            ),
            _buildSidebarItem(
              local.translate('support'),
              LucideIcons.headphones,
              3,
              theme,
            ),
            _buildSidebarItem(
              local.translate('settings'),
              LucideIcons.settings,
              4,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(ThemeData theme, AppLocalizations local) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(theme),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(
                  local.translate('home'),
                  LucideIcons.home,
                  0,
                  theme,
                ),
                _buildSidebarItem(
                  local.translate('my_trips'),
                  LucideIcons.car,
                  1,
                  theme,
                ),
                _buildSidebarItem(
                  local.translate('earnings'),
                  LucideIcons.dollarSign,
                  2,
                  theme,
                ),
                _buildSidebarItem(
                  local.translate('support'),
                  LucideIcons.headphones,
                  3,
                  theme,
                ),
                _buildSidebarItem(
                  local.translate('settings'),
                  LucideIcons.settings,
                  4,
                  theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Icon(
            LucideIcons.car,
            size: 60,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 15),
          Text(
            "TaxiGo Driver",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Divider(
            color: theme.colorScheme.onPrimary.withOpacity(0.2),
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title,
    IconData icon,
    int index,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _selectedIndex == index
            ? theme.colorScheme.secondary.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: _selectedIndex == index
              ? theme.colorScheme.secondary
              : theme.colorScheme.onPrimary.withOpacity(0.8),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: _selectedIndex == index
                ? theme.colorScheme.secondary
                : theme.colorScheme.onPrimary,
            fontWeight: _selectedIndex == index ? FontWeight.bold : null,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme, AppLocalizations local) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.primary,
      selectedItemColor: theme.colorScheme.onPrimary,
      unselectedItemColor: theme.colorScheme.onPrimary.withOpacity(0.6),
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.home),
          label: local.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.car),
          label: local.translate('my_trips'),
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.dollarSign),
          label: local.translate('earnings'),
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.headphones),
          label: local.translate('support'),
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.settings),
          label: local.translate('settings'),
        ),
      ],
    );
  }
}
