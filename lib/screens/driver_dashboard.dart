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

    // Titles need to be initialized after context is available for localization
    // For now, we'll use placeholder strings and update them in build if needed,
    // or rely on _buildAppBarTitle which will use local.translate
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
      // Access verification
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
      // Check if user exists and is logged in
      if (userData['user'] == null || userData['user']?['isLoggedIn'] != true) {
        _handleAccessDenied();
        return;
      }

      // Fetch driver data if verification is successful
      await _loadDriverData();

      setState(() {
        _accessGranted = true;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error during verification: $e');
      }
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

  void _handleAccessDenied() {
    if (!mounted) return;

    // Use a Future.delayed to ensure dialog is shown after build context is stable
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context).translate('access_denied')),
          content: Text(AppLocalizations.of(context)
              .translate('login_required_driver')), // Added specific message
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
                // Pop all routes until the first one (login screen)
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
                  Theme.of(context).colorScheme.primary), // Use theme color
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.2), // Lighter background
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

  // Define which pages are part of the bottom navigation bar
  final List<int> _bottomNavBarPagesIndices = [0, 1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    if (!_accessGranted || _isLoading) {
      return _buildLoadingScreen();
    }

    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > _kWebBreakpoint;
    final local = AppLocalizations.of(context);

    // Update page titles with localization
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
        foregroundColor: theme.colorScheme.onPrimary, // Icon/text color
        elevation:
            isLargeScreen ? 0 : 4, // No elevation on web, subtle on mobile
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
          if (isLargeScreen) // Settings icon only on web app bar
            IconButton(
              icon: Icon(LucideIcons.settings,
                  color: theme.colorScheme.onPrimary),
              tooltip: local.translate('settings'),
              onPressed: () => _navigateToPage(5), // Navigate to Settings page
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
      backgroundColor:
          theme.colorScheme.background, // Lighter background for drawer
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
      width: 280, // Slightly wider sidebar for desktop
      child: Container(
        decoration: BoxDecoration(
          color: theme
              .colorScheme.primary, // Primary color for the sidebar background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(3, 0), // Shadow to the right
            ),
          ],
        ),
        child: Column(
          children: [
            // Sidebar header (same content for consistency)
            _buildSidebarHeaderContent(theme, local, isDesktop: true),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Remove default padding
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
            // Larger, more prominent
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
        if (isDesktop) // Only show divider for desktop sidebar header
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
    bool isDrawer = false, // To handle Drawer close behavior
  }) {
    final bool isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent, // Ensure no default material color
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          if (isDrawer) {
            Navigator.of(context).pop(); // Close the drawer on item tap
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.secondary
                    .withOpacity(0.2) // Highlight color
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10), // Slightly rounded corners
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
                    ? theme.colorScheme.secondary // Icon color for selected
                    : theme.colorScheme.onPrimary
                        .withOpacity(0.8), // Default icon color
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    // Slightly larger text
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
            Navigator.of(context).pop(); // Close drawer before navigating
          }
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.messageSquare, // More appropriate icon for chat
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  local.translate('chat'), // Translate 'الدردشة'
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
    // Find the current index within the bottom navigation bar's page subset
    final currentBottomNavIndex =
        _bottomNavBarPagesIndices.indexOf(_selectedIndex);

    return BottomNavigationBar(
      currentIndex: currentBottomNavIndex == -1
          ? 0
          : currentBottomNavIndex, // Default to 0 if not in list
      onTap: (index) {
        setState(() {
          _selectedIndex = _bottomNavBarPagesIndices[index];
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.primary,
      selectedItemColor:
          theme.colorScheme.onPrimary, // Selected item text/icon color
      unselectedItemColor:
          theme.colorScheme.onPrimary.withOpacity(0.6), // Unselected
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
