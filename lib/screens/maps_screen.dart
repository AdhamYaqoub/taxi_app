import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // لإضافة Timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  LocationData? currentLocation;
  LatLng? destination;
  List<LatLng> routePoints = [LatLng(0, 0)];
  List<Marker> markers = [];
  bool isRouteBlocked = false;
  final String orsApiKey = '5b3ce3597851110001cf62485bf8e58a124640b1bc61ce2b4825433e';
  final String botToken = '7608922442:AAHaWNXgfJFxgPBi2VJgdWekfznFIQ-4ZOQ';
  final String chatId = '-1002436928564';
  Timer? _timer; // Timer للفحص التلقائي
  double? deviceDirection = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startRouteStatusChecker(); // بدء الفحص التلقائي
    _listenToDeviceDirection(); // بدء الاستماع لاتجاه الجهاز
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف الـ Timer عند إغلاق الصفحة
    super.dispose();
  }

  // بدء الفحص التلقائي كل 3 ثواني
  void _startRouteStatusChecker() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _checkRouteStatus();
    });
  }

  // الحصول على الموقع الحالي للمستخدم
  Future<void> _getCurrentLocation() async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            child: const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
          ),
        );
      });
    } catch (e) {
      currentLocation = null;
    }
  }

  // البحث عن المكان
  Future<void> _searchLocation(String placeName) async {
    if (placeName.isEmpty) return;

    final response = await http.get(
      Uri.parse('https://nominatim.openstreetmap.org/search?q=$placeName&format=json'),
    );

    if (response.statusCode != 200) return;

    final List<dynamic> data = json.decode(response.body);
    if (data.isEmpty) return;

    final double lat = double.parse(data[0]['lat']);
    final double lon = double.parse(data[0]['lon']);
    setState(() {
      destination = LatLng(lat, lon);
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: destination!,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
        ),
      );
      mapController.move(destination!, 15.0);
    });
  }

  // الحصول على المسار من API
  Future<void> _getRoute() async {
    if (currentLocation == null || destination == null) return;

    final start = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination!.longitude},${destination!.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'].isNotEmpty) {
        final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
        if (coords.isNotEmpty) {
          setState(() {
            routePoints = coords.map((coord) => LatLng(coord[1], coord[0])).toList();
          });
        }
      }
    }
  }

  // التحقق من حالة الطريق من التلجرام
  Future<void> _checkRouteStatus() async {
    final response = await http.get(
      Uri.parse('https://api.telegram.org/bot$botToken/getUpdates?chat_id=$chatId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> updates = data['result'];
      if (updates.isNotEmpty) {
        final String lastMessage = updates.last['message']['text'] ?? '';
        setState(() {
          isRouteBlocked = lastMessage.contains('مسكرة'); // تغيير الشرط حسب الرسالة
        });
      }
    }
  }

  // تحديث اتجاه الجهاز
  void _listenToDeviceDirection() {
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        deviceDirection = event.heading;
      });
      _updateUserMarker();
    });
  }

  // تحديث رمز المستخدم مع اتجاه الجهاز
  void _updateUserMarker() {
    if (currentLocation == null) return;
    markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        child: Transform.rotate(
          angle: (deviceDirection ?? 0) * (3.14159265359 / 180),
          child: const Icon(Icons.navigation, color: Colors.blue, size: 50.0),
        ),
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenStreetMap مع Flutter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن مكان...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(searchController.text);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: markers),
                      PolylineLayer<LatLng>(polylines: [
                        Polyline<LatLng>( 
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: isRouteBlocked ? Colors.red : Colors.blue,
                        ),
                      ]),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (destination != null) {
                _getRoute();
              }
            },
            tooltip: 'ابدأ المسار',
            child: const Icon(Icons.directions),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              if (currentLocation != null) {
                mapController.move(
                  LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  15.0,
                );
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
