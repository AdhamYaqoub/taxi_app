import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart'; // Ensure this path is correct
import 'package:taxi_app/screens/Driver/driver_requests.dart';
import 'package:taxi_app/screens/components/NotificationIcon.dart'; // Ensure this path is correct
import 'Driver/driver_home.dart';
import 'Driver/driver_trips.dart';
import 'Driver/earnings.dart';
import 'Driver/driver_settings.dart';
import 'Driver/support.dart';
import 'chat.dart'; // Ensure this path is correct

class DriverDashboard extends StatefulWidget {
  final int userId;
  final String token;

  const DriverDashboard({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0;
  late List<Widget> _pages;
  String? _fullName;
  bool _isLoading = true;
  bool _accessGranted = false;

  // Define a breakpoint for web layout (e.g., 800 pixels)
  static const double _kWebBreakpoint = 800.0;

  // List of page titles for the AppBar
  late List<String> _pageTitles;

  @override
  void initState() {
    super.initState();
    _initializePagesAndTitles();
    _verifyAndLoadData();
  }

  void _initializePagesAndTitles() {
    _pages = [
      DriverHomePage(driverId: widget.userId),
      DriverRequestsPage(driverId: widget.userId),
      DriverTripsPage(driverId: widget.userId),
      EarningsPage(driverId: widget.userId),
      SupportPage(),
      DriverSettingsPage(
        driverId: widget.userId,
        onAvailabilityChanged: (bool value) {}, // Keep this placeholder
      ),
    ];

    _pageTitles = [
      'Home',
      'Trip Requests',
      'My Trips',
      'Earnings',
      'Support',
      'Settings',
    ];
  }

  Future<void> _verifyAndLoadData() async {
    try {
      // --- Step 1: Verify user's basic info (isLoggedIn and role) ---
      final userAccessResponse = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/users/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (userAccessResponse.statusCode != 200) {
        _handleAccessDenied(
            AppLocalizations.of(context).translate('access_denied_general'));
        return;
      }

      final userData = jsonDecode(userAccessResponse.body);
      print('User data from /api/users: $userData'); // Debugging user data

      final userDetails = userData['user'];

      // Check if user object exists and is logged in
      if (userDetails == null || userDetails['isLoggedIn'] != true) {
        _handleAccessDenied(
            AppLocalizations.of(context).translate('login_required_driver'));
        return;
      }

      final String? userRole = userDetails['role'];

      // Check if the user's role is 'Driver'
      if (userRole != 'Driver') {
        _handleAccessDenied(AppLocalizations.of(context)
            .translate('access_denied_not_driver')); // Add this translation key
        return;
      }

      // --- Step 2: If user is a logged-in Driver, fetch driver-specific details (including isAvailable) ---
      // This calls the new backend endpoint designed to return driver status
      final driverStatusResponse = await http.get(
        Uri.parse(
            '${dotenv.env['BASE_URL']}/api/drivers/status/${widget.userId}'), // ✅ NEW ENDPOINT
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (driverStatusResponse.statusCode != 200) {
        // If driver details cannot be fetched, it's an access issue or missing driver data
        _handleAccessDenied(AppLocalizations.of(context)
            .translate('driver_details_not_found')); // Add this translation key
        return;
      }

      final driverData = jsonDecode(driverStatusResponse.body);
      print(
          'Driver data from /api/drivers/status: $driverData'); // Debugging driver-specific data

      // Now check if the driver is available from the driverData
      final bool isAvailable = driverData['isAvailable'] == true;

      if (!isAvailable) {
        _handleAccessDenied(AppLocalizations.of(context)
            .translate('driver_not_available')); // Add this translation key
        return;
      }

      // All checks passed: user exists, is logged in, is a Driver, and is available
      // Load full name (can be optimized if driverData already includes it reliably)
      await _loadDriverData();

      setState(() {
        _accessGranted = true;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error during verification: $e');
      }
      _handleAccessDenied(
          AppLocalizations.of(context).translate('error_verifying_access'));
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
      } else {
        if (kDebugMode) {
          print('Failed to load full name: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading driver data: $e');
      }
    }
  }

  void _handleAccessDenied(String message) {
    if (!mounted) return;

    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).translate('access_denied')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text(AppLocalizations.of(context).translate('ok')),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('verifying_access'),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate('please_wait'),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<int> _bottomNavBarPagesIndices = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    if (!_accessGranted || _isLoading) {
      return _buildLoadingScreen();
    }

    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > _kWebBreakpoint;
    final local = AppLocalizations.of(context);

    _pageTitles = [
      local.translate('home'),
      local.translate('trip_requests'),
      local.translate('my_trips'),
      local.translate('earnings'),
      local.translate('support'),
      local.translate('settings'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: isLargeScreen ? 0 : 4,
        title: Text(
          _pageTitles[_selectedIndex],
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NotificationIcon(userId: widget.userId),
          const SizedBox(width: 8),
          if (isLargeScreen)
            IconButton(
              icon: Icon(LucideIcons.settings,
                  color: theme.colorScheme.onPrimary),
              tooltip: local.translate('settings'),
              onPressed: () => _navigateToPage(5),
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isLargeScreen ? null : _buildMobileDrawer(theme, local),
      body: isLargeScreen
          ? Row(
              children: [
                _buildDesktopSidebar(theme, local),
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            )
          : _pages[_selectedIndex],
      bottomNavigationBar:
          isLargeScreen ? null : _buildBottomNavBar(theme, local),
    );
  }

  Widget _buildMobileDrawer(ThemeData theme, AppLocalizations local) {
    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: _buildSidebarHeaderContent(theme, local),
            ),
            _buildSidebarItem(
                local.translate('home'), LucideIcons.home, 0, theme,
                isDrawer: true),
            _buildSidebarItem(
                local.translate('trip_requests'), LucideIcons.list, 1, theme,
                isDrawer: true),
            _buildSidebarItem(
                local.translate('my_trips'), LucideIcons.car, 2, theme,
                isDrawer: true),
            _buildSidebarItem(
                local.translate('earnings'), LucideIcons.dollarSign, 3, theme,
                isDrawer: true),
            _buildSidebarItem(
                local.translate('support'), LucideIcons.headphones, 4, theme,
                isDrawer: true),
            _buildSidebarItem(
                local.translate('settings'), LucideIcons.settings, 5, theme,
                isDrawer: true),
            Divider(color: theme.dividerColor.withOpacity(0.5), height: 1),
            _buildChatListItem(theme, local, isDrawer: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(ThemeData theme, AppLocalizations local) {
    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSidebarHeaderContent(theme, local, isDesktop: true),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
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
                  Divider(
                      color: theme.colorScheme.onPrimary.withOpacity(0.2),
                      height: 1),
                  _buildChatListItem(theme, local),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeaderContent(ThemeData theme, AppLocalizations local,
      {bool isDesktop = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.car,
          size: 60,
          color: theme.colorScheme.onPrimary,
        ),
        const SizedBox(height: 10),
        Text(
          "TaxiGo Driver",
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_fullName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _fullName!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 15),
        if (isDesktop)
          Divider(
            color: theme.colorScheme.onPrimary.withOpacity(0.2),
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildSidebarItem(
    String title,
    IconData icon,
    int index,
    ThemeData theme, {
    bool isDrawer = false,
  }) {
    final bool isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (isDrawer) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.secondary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.secondary.withOpacity(0.4),
                    width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.onPrimary.withOpacity(0.8),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatListItem(ThemeData theme, AppLocalizations local,
      {bool isDrawer = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isDrawer) {
            Navigator.of(context).pop();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: widget.userId,
                userType: 'Driver',
                token: widget.token,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.messageSquare,
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  local.translate('chat'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(ThemeData theme, AppLocalizations local) {
    final currentBottomNavIndex =
        _bottomNavBarPagesIndices.indexOf(_selectedIndex);

    return BottomNavigationBar(
      currentIndex: currentBottomNavIndex == -1 ? 0 : currentBottomNavIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = _bottomNavBarPagesIndices[index];
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.primary,
      selectedItemColor: theme.colorScheme.onPrimary,
      unselectedItemColor: theme.colorScheme.onPrimary.withOpacity(0.6),
      selectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onPrimary,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onPrimary.withOpacity(0.6),
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

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
