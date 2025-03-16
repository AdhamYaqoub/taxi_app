import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bot_service.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MapScreen(),
//     );
//   }
// }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<List<LatLng>> routePoints = [];
  LatLng? startPoint;
  LatLng? endPoint;
  LocationData? currentLocation;
  Color routeColor = Colors.green; // اللون الافتراضي للطريق


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // الحصول على الموقع الحالي للمستخدم
  Future<void> _getCurrentLocation() async {
    var location = Location();

    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        startPoint = LatLng(userLocation.latitude!, userLocation.longitude!);
      });
    } on Exception {
      currentLocation = null;
    }

    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
      });
    });
  }

  // تحميل المسارات الثلاثة
  Future<void> getRoutes(LatLng start, LatLng end) async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?alternatives=3&overview=full&geometries=geojson";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List routes = data['routes'];

      setState(() {
        routePoints = routes.map((route) {
          final List coordinates = route['geometry']['coordinates'];
          return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        }).toList();
      });
    } else {
      print("Failed to load routes");
    }
  }

  // تحديد النقطة الثانية عند الضغط على الخريطة
  void _onMapTap(LatLng point) {
    setState(() {
      endPoint = point;
      // تحميل المسارات بعد تحديد النقطة الثانية
      if (startPoint != null && endPoint != null) {
        getRoutes(startPoint!, endPoint!);
      }
    });
  }

  // تحديد اللون للمسارات بناءً على المسافة والازدحام
  Color _getRouteColor(int index) {
    if (routeColor == Colors.red) {
      return Colors.red; // إذا كان الطريق مسكرًا
    } else if (routeColor == Colors.yellow) {
      return Colors.yellow; // إذا كان الطريق مزدحمًا
    } else {
      return Colors.green; // الطريق الطبيعي
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Free Routing with OSM")),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                minZoom: 13.0,
                onTap: (tapPosition, point) => _onMapTap(point), // عند الضغط على الخريطة
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (startPoint != null)
                      Marker(
                        point: startPoint!,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_pin, color: Colors.green, size: 40),
                      ),
                    if (endPoint != null)
                      Marker(
                        point: endPoint!,
                        width: 40,
                        height: 40,
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                  ],
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: routePoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final points = entry.value;
                      return Polyline(
                        points: points,
                        strokeWidth: 6.0,
                        color: _getRouteColor(index), // تعيين اللون بناءً على فهرس الرسالة
                      );
                    }).toList(),
                  ),
              ],
            ),
    );
  }
}
