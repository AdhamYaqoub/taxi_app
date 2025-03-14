import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:taxi_app/screens/ProfileScreen.dart';
// import 'package:taxi_app/screens/signin_screen.dart';
// import 'package:taxi_app/screens/signup_screen.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';

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
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWeb = constraints.maxWidth > 800;
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.colorScheme.surface,
  appBar: CustomAppBar(selectedLanguage: selectedLanguage),


          drawer: isWeb ? null : _buildDrawer(theme),
          body: isWeb ? _buildWebLayout(theme) : _buildMobileLayout(theme),
        );
      },
    );
  }

  /// 🗂️ تصميم الشريط الجانبي للويب

  /// 🗂️ تصميم الشريط الجانبي للموبايل
  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Text(
              selectedLanguage == 'Arabic' ? 'القائمة' : 'Menu',
              style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: theme.colorScheme.onSurface),
            title: Text(selectedLanguage == 'Arabic' ? 'الرئيسية' : 'Home', style: theme.textTheme.bodyLarge),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
            title: Text(selectedLanguage == 'Arabic' ? 'السجل' : 'History', style: theme.textTheme.bodyLarge),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
            title: Text(selectedLanguage == 'Arabic' ? 'الإعدادات' : 'Settings', style: theme.textTheme.bodyLarge),
            onTap: () {},
          ),
        ],
      ),
    );
  }
  Widget _buildSidebar(ThemeData theme) {
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.home, color: theme.colorScheme.onSurface),
            title: Text(selectedLanguage == 'Arabic' ? 'الرئيسية' : 'Home', style: theme.textTheme.bodyLarge),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.onSurface),
            title: Text(selectedLanguage == 'Arabic' ? 'السجل' : 'History', style: theme.textTheme.bodyLarge),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.onSurface),
            title: Text(selectedLanguage == 'Arabic' ? 'الإعدادات' : 'Settings', style: theme.textTheme.bodyLarge),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// ✅ تصميم الموبايل: قائمة جانبية، حقول إدخال رأسية، وخريطة منبثقة
  Widget _buildMobileLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(_pickUpController, Icons.location_on, 'موقع الالتقاط', 'Pick-up Location', theme, _getLocation),
          const SizedBox(height: 10),
          _buildTextField(_dropOffController, Icons.location_off, 'موقع التسليم', 'Drop-off Location', theme),
          const SizedBox(height: 10),
          _buildDateTimeFields(theme),
          const SizedBox(height: 10),
          _buildEstimateButton(theme),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showMapDialog(context),
            child: _buildMapThumbnail(),
          ),
        ],
      ),
    );
  }

  /// ✅ تصميم الويب: شريط جانبي، حقول إدخال في صفوف، وخريطة على اليمين
  Widget _buildWebLayout(ThemeData theme) {
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
                    Expanded(child: _buildTextField(_pickUpController, Icons.location_on, 'موقع الالتقاط', 'Pick-up Location', theme, _getLocation)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(_dropOffController, Icons.location_off, 'موقع التسليم', 'Drop-off Location', theme)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDateTimeFields(theme),
                const SizedBox(height: 10),
                _buildEstimateButton(theme),
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

  /// 🗺️ تصميم مصغر للخريطة عند النقر عليها في الموبايل
  Widget _buildMapThumbnail() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('../../assets/map.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// 🗺️ تصميم الخريطة الكبيرة للويب
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

  /// 🎨 عناصر الإدخال للنصوص
  Widget _buildTextField(TextEditingController controller, IconData icon, String arLabel, String enLabel, ThemeData theme, [VoidCallback? onPressed]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: selectedLanguage == 'Arabic' ? arLabel : enLabel,
        border: OutlineInputBorder(),
        suffixIcon: onPressed != null ? IconButton(icon: Icon(icon), onPressed: onPressed) : null,
      ),
    );
  }

  /// 📅 عناصر الإدخال للتاريخ والوقت
  Widget _buildDateTimeFields(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(_dateController, Icons.date_range, 'التاريخ', 'Date', theme, () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              setState(() {
                _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
              });
            }
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(_timeController, Icons.access_time, 'الوقت', 'Time', theme, () async {
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

  /// 🗺️ عرض الخريطة في حوار
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

  /// 🎯 زر تقدير السعر
  Widget _buildEstimateButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(selectedLanguage == 'Arabic' ? 'تم تقدير السعر!' : 'Price Estimated!'),
        ));
      },
      child: Text(selectedLanguage == 'Arabic' ? 'تقدير السعر' : 'Estimate Price'),
    );
  }
}
