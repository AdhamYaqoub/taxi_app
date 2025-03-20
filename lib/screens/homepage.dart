import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taxi_app/screens/admin.dart';
import 'package:taxi_app/screens/maps_screen.dart';
import 'package:taxi_app/screens/pyment.dart';
import 'package:taxi_app/screens/setting.dart';
import 'package:taxi_app/screens/smile.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
import 'package:taxi_app/language/localization.dart'; // استيراد AppLocalizations
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedLanguage = 'Arabic';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LatLng _center = LatLng(37.7749, -122.4194);
  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _dropOffController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  LatLng? _pickUpLocation;
  LatLng? _dropOffLocation;

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // إذا رفض المستخدم الإذن بشكل دائم، يمكن فتح إعدادات الجهاز
        openAppSettings();
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _pickUpLocation = LatLng(position.latitude, position.longitude);
      _pickUpController.text = '${position.latitude}, ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    // استخدام الترجمة من AppLocalizations
    String homeText = AppLocalizations.of(context).translate('home');
    String historyText = AppLocalizations.of(context).translate('history');
    String settingsText = AppLocalizations.of(context).translate('settings');
    String adminText = AppLocalizations.of(context).translate('admin');
    String menuText = AppLocalizations.of(context).translate('menu');
    String pickUpLocationText =
        AppLocalizations.of(context).translate('pick_up_location');
    String dropOffLocationText =
        AppLocalizations.of(context).translate('drop_off_location');
    String dateText = AppLocalizations.of(context).translate('date');
    String timeText = AppLocalizations.of(context).translate('time');
    String estimatePriceText =
        AppLocalizations.of(context).translate('estimate_price');

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWeb = constraints.maxWidth > 800;
        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(),
          drawer: isWeb
              ? null
              : _buildDrawer(theme, homeText, historyText, settingsText,
                  menuText, adminText),
          body: isWeb
              ? _buildWebLayout(theme, pickUpLocationText, dropOffLocationText,
                  dateText, timeText, estimatePriceText)
              : _buildMobileLayout(theme, pickUpLocationText,
                  dropOffLocationText, dateText, timeText, estimatePriceText),
        );
      },
    );
  }

  Widget _buildDrawer(ThemeData theme, String homeText, String historyText,
      String settingsText, String menuText, String adminText) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Text(
              selectedLanguage == 'Arabic' ? menuText : 'Menu',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: theme.colorScheme.onSurface),
            title: Text(homeText, style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MapScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
            title: Text(historyText, style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PaymentScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
            title: Text(settingsText, style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
            title: Text(adminText, style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context); // إغلاق القائمة
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AdminDashboard()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      ThemeData theme,
      String pickUpLocationText,
      String dropOffLocationText,
      String dateText,
      String timeText,
      String estimatePriceText) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(_pickUpController, Icons.location_on,
              pickUpLocationText, 'Pick-up Location', theme, _getLocation),
          const SizedBox(height: 10),
          _buildTextField(_dropOffController, Icons.location_off,
              dropOffLocationText, 'Drop-off Location', theme),
          const SizedBox(height: 10),
          _buildDateTimeFields(theme, dateText, timeText),
          const SizedBox(height: 10),
          _buildEstimateButton(theme, estimatePriceText),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showMapDialog(context),
            child: _buildMapThumbnail(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(
      ThemeData theme,
      String pickUpLocationText,
      String dropOffLocationText,
      String dateText,
      String timeText,
      String estimatePriceText) {
    return Row(
      children: [
        _buildSidebar(theme),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            _pickUpController,
                            Icons.location_on,
                            pickUpLocationText,
                            'Pick-up Location',
                            theme,
                            _getLocation)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _buildTextField(
                            _dropOffController,
                            Icons.location_off,
                            dropOffLocationText,
                            'Drop-off Location',
                            theme)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDateTimeFields(theme, dateText, timeText),
                const SizedBox(height: 10),
                _buildEstimateButton(theme, estimatePriceText),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildMapView(),
        ),
      ],
    );
  }

  Widget _buildMapThumbnail() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/map.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _center,
        minZoom: 1.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon,
      String arLabel, String enLabel, ThemeData theme,
      [VoidCallback? onPressed]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: selectedLanguage == 'Arabic' ? arLabel : enLabel,
        border: OutlineInputBorder(),
        suffixIcon: onPressed != null
            ? IconButton(icon: Icon(icon), onPressed: onPressed)
            : null,
      ),
    );
  }

  Widget _buildDateTimeFields(
      ThemeData theme, String dateText, String timeText) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
              _dateController, Icons.date_range, dateText, 'Date', theme,
              () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                _dateController.text =
                    DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(
              _timeController, Icons.access_time, timeText, 'Time', theme,
              () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              setState(() {
                _timeController.text = pickedTime.format(context);
              });
            }
          }),
        ),
      ],
    );
  }

  void _showMapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: _buildMapView(),
          ),
        );
      },
    );
  }

  Widget _buildEstimateButton(ThemeData theme, String estimatePriceText) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(selectedLanguage == 'Arabic'
              ? 'قيمة التقدير'
              : 'Estimated price'),
        ));
      },
      child: Text(estimatePriceText),
    );
  }

  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('menu'),
              style: theme.textTheme.headlineSmall),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('home')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('history')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('settings')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('admin')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            },
          ),
        ],
      ),
    );
  }
}