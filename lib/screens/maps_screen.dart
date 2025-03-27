import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final String mapboxAccessToken = "pk.eyJ1IjoiYWRoYW15YXFvdWIiLCJhIjoiY204M2d3c2Y0MTVtcjJqcXJwYm5ybWF3MyJ9.dISrwzTh0ZHENDm-MxEGwA";
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // San Francisco
  final List<Marker> _markers = [];
  final List<List<LatLng>> _routeOptions = [];
  final List<double> _routeDurations = [];
  late Marker _carMarker;
  String _estimatedTime = "";
  List<String> closedRoads = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  // طلب الموقع عند بداية التطبيق
  }

  Future<void> _getCurrentLocation() async {
    // التحقق إذا كان لدينا إذن للوصول إلى الموقع
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // إذا كان الإذن مرفوضًا، عرض رسالة للمستخدم
      return;
    }

    // إذا كان الإذن معطى، نحدد الموقع الحالي
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);  // تعيين الموقع الحالي كنقطة بداية
      _carMarker = Marker(
        width: 50.0,
        height: 50.0,
        point: _initialPosition,
        child: Icon(Icons.directions_car, color: Colors.black, size: 40),
      );
    });
    _mapController.move(_initialPosition, 14.0);  // تحريك الخريطة إلى الموقع الحالي
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=$mapboxAccessToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'].isNotEmpty) {
        final place = data['features'][0];
        final location = LatLng(place['center'][1], place['center'][0]);
        setState(() {
          _markers.add(Marker(
            width: 80.0,
            height: 80.0,
            point: location,
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ));
        });
        _mapController.move(location, 14.0);
      }
    }
  }

  Future<void> _drawRoutes(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&alternatives=true&access_token=$mapboxAccessToken');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _routeOptions.clear();
        _routeDurations.clear();
        for (var route in data['routes']) {
          final coordinates = route['geometry']['coordinates'] as List;
          final duration = route['duration'] / 60; // تحويل الوقت من ثواني إلى دقائق
          _routeDurations.add(duration);
          _routeOptions.add(coordinates.map((coord) => LatLng(coord[1], coord[0])).toList());
        }
        _estimatedTime = "${_routeDurations[0].toStringAsFixed(1)} دقيقة";
      });
    }
  }

  void _startNavigation() {
    if (_routeOptions.isNotEmpty) {
      setState(() {
        // Create dynamic polyline based on route options
        // For now, just show the first available route
        _routeOptions.forEach((route) {
          PolylineLayer(
            polylines: [
              Polyline(
                points: route,
                strokeWidth: 4.0,
                color: Colors.blue,  // or logic based on the route
              ),
            ],
          );
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("الخريطة التفاعلية - Mapbox")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              maxZoom: 18,
              onTap: (tapPosition, point) {
                if (_markers.length >= 2) {
                  _markers.clear();
                  _routeOptions.clear();
                  _routeDurations.clear();
                }
                setState(() {
                  _markers.add(Marker(
                    width: 80.0,
                    height: 80.0,
                    point: point,
                    child: Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ));
                });
                if (_markers.length == 2) {
                  _drawRoutes(_markers[0].point, _markers[1].point);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken",
                additionalOptions: {'access_token': mapboxAccessToken},
              ),
              if (_routeOptions.isNotEmpty)
                PolylineLayer(
                  polylines: _routeOptions
                      .asMap()
                      .entries
                      .map(
                        (entry) => Polyline(
                          points: entry.value,
                          strokeWidth: 4.0,
                          color: closedRoads.contains(entry.value.toString())
                              ? Colors.red
                              : entry.key == 0
                                  ? Colors.blue
                                  : Colors.green,
                        ),
                      )
                      .toList(),
                ),
              MarkerLayer(markers: [..._markers, _carMarker]),
            ],
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: TextField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "ابحث عن مكان...",
                hintStyle: TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: Icon(Icons.search, color: Colors.black),
              ),
              onSubmitted: (value) => _searchLocation(value),
            ),
          ),
          if (_routeDurations.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 15,
              right: 15,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 16, 15, 15),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("المسافة: ${(_routeDurations[0] * 1.5).toStringAsFixed(1)} كم",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("الوقت المتوقع: $_estimatedTime",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: _startNavigation,
                      child: Text("ابدأ الرحلة"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
