import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/screens/Driver/driver_requests.dart';
import 'Driver/driver_home.dart';
import 'Driver/driver_trips.dart';
import 'Driver/earnings.dart';
import 'Driver/driver_settings.dart';
import 'Driver/support.dart';
import 'chat.dart';

class DriverDashboard extends StatefulWidget {
  final int userId;
  final String token;

  const DriverDashboard({super.key, required this.userId, required this.token});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
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
      DriverHomePage(driverId: widget.userId),
      DriverRequestsPage(driverId: widget.userId),
      DriverTripsPage(driverId: widget.userId),
      EarningsPage(driverId: widget.userId),
      SupportPage(),
      DriverSettingsPage(
        driverId: widget.userId,
        onAvailabilityChanged: (bool value) {},
      ),
    ];
  }

  Future<void> _verifyAndLoadData() async {
    try {
      // التحقق من صلاحية السائق
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
      if (userData['user']?['isLoggedIn'] != true) {
        _handleAccessDenied();
        return;
      }

      // جلب بيانات السائق إذا التحقق ناجح
      await _loadDriverData();

      setState(() {
        _accessGranted = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error during verification: $e');
      _handleAccessDenied();
    }
  }

  Future<void> _loadDriverData() async {
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
      print('Error loading driver data: $e');
    }
  }

  void _handleAccessDenied() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('access_denied')),
        content: Text(AppLocalizations.of(context).translate('login_required')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // إغلاق الـ AlertDialog
              Navigator.of(context)
                  .popUntil((route) => route.isFirst); // العودة للشاشة الأولى
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

  final List<int> _bottomNavBarPages = [
    0,
    1,
    2,
    3,
    4
  ]; // استثناء صفحة الإعدادات

  @override
  Widget build(BuildContext context) {
    if (!_accessGranted || _isLoading) {
      return _buildLoadingScreen();
    }

    final theme = Theme.of(context);
    final isWeb = MediaQuery.of(context).size.width > 800;
    final local = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isWeb
          ? AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.translate('driver_dashboard'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      inherit: true,
                    ),
                  ),
                  if (_fullName != null)
                    Text(
                      _fullName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            )
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text(
                local.translate('driver_dashboard'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  inherit: true,
                ),
              ),
            ),
      drawer: isWeb ? null : _buildMobileSidebar(theme, local),
      body: isWeb
          ? Row(
              children: [
                _buildDesktopSidebar(theme, local),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            )
          : _pages[_selectedIndex],
      bottomNavigationBar: isWeb ? null : _buildBottomNavBar(theme, local),
    );
  }

  Widget _buildMobileSidebar(ThemeData theme, AppLocalizations local) {
    return Drawer(
      backgroundColor: theme.colorScheme.primary,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildSidebarHeader(theme),
            _buildSidebarItem(
                local.translate('home'), LucideIcons.home, 0, theme),
            _buildSidebarItem(
                local.translate('trip_requests'), LucideIcons.list, 1, theme),
            _buildSidebarItem(
                local.translate('my_trips'), LucideIcons.car, 2, theme),
            _buildSidebarItem(
                local.translate('earnings'), LucideIcons.dollarSign, 3, theme),
            _buildSidebarItem(
                local.translate('support'), LucideIcons.headphones, 4, theme),
            _buildSidebarItem(
                local.translate('settings'), LucideIcons.settings, 5, theme),
            ListTile(
              leading: Icon(Icons.chat,
                  color: theme.colorScheme.onPrimary.withOpacity(0.8)),
              title: Text(
                'الدردشة',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userId: widget.userId.toString(),
                      userType: 'driver',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(ThemeData theme, AppLocalizations local) {
    return SizedBox(
      width: 250,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          color: theme.colorScheme.primary,
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
                      local.translate('trip_requests'),
                      LucideIcons.list,
                      1,
                      theme,
                    ),
                    _buildSidebarItem(
                      local.translate('my_trips'),
                      LucideIcons.car,
                      2,
                      theme,
                    ),
                    _buildSidebarItem(
                      local.translate('earnings'),
                      LucideIcons.dollarSign,
                      3,
                      theme,
                    ),
                    _buildSidebarItem(
                      local.translate('support'),
                      LucideIcons.headphones,
                      4,
                      theme,
                    ),
                    _buildSidebarItem(
                      local.translate('settings'),
                      LucideIcons.settings,
                      5,
                      theme,
                    ),
                    ListTile(
                      leading: Icon(Icons.chat,
                          color: theme.colorScheme.onPrimary.withOpacity(0.8)),
                      title: Text(
                        'الدردشة',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              userId: widget.userId.toString(),
                              userType: 'driver',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
              inherit: true,
            ),
          ),
          if (_fullName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _fullName!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
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
            inherit: true,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme, AppLocalizations local) {
    final currentBottomNavIndex = _bottomNavBarPages.contains(_selectedIndex)
        ? _bottomNavBarPages.indexOf(_selectedIndex)
        : 0;

    return BottomNavigationBar(
      currentIndex: currentBottomNavIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = _bottomNavBarPages[index];
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.primary,
      selectedItemColor: theme.colorScheme.onPrimary,
      unselectedItemColor: theme.colorScheme.onPrimary.withOpacity(0.6),
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        inherit: true,
      ),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.home),
          label: local.translate('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.list),
          label: local.translate('trip_requests'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.car),
          label: local.translate('my_trips'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.dollarSign),
          label: local.translate('earnings'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(LucideIcons.headphones),
          label: local.translate('support'),
        ),
      ],
    );
  }
}
