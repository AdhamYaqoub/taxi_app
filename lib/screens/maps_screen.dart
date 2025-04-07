// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
// import 'dart:math';

// void main() {
//   runApp(TaxiApp());
// }

// class TaxiApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'تطبيق التكسي الذكي',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Tajawal',
//       ),
//       home: MapScreen(),
//     );
//   }
// }

// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final MapController _mapController = MapController();
//   final TextEditingController _searchController = TextEditingController();
//   final Location _locationService = Location();
  
//   LocationData? _currentLocation;
//   LatLng? _destination;
//   List<LatLng> _routePoints = [];
//   List<LatLng> _alternativeRoute = [];
//   List<LatLng> _blockedRoads = [];
//   Map<LatLng, DateTime> _blockedRoadsExpiry = {};
//   List<Marker> _markers = [];
//   bool _isRouteBlocked = false;
//   double? _deviceDirection;
//   Timer? _locationTimer;
//   Timer? _telegramTimer;
//   Timer? _expiryTimer;
//   bool _isLoading = false;

//   // Telegram message analysis variables
//   final List<String> _blockedKeywords = ['مسكرة', 'مغلقة', 'إغلاق', 'تحويلة', 'اغلاق', 'سد'];
//   final List<String> _unblockedKeywords = ['فتحت', 'انتهى', 'انحلت', 'فتح', 'فتوحة'];
//   final List<String> _adminKeywords = ['بلدية', 'مرور', 'دفاع مدني', 'شرطة', 'داخلية'];

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     await _getCurrentLocation();
//     _listenToCompass();
//     _startTimers();
//   }

//   void _startTimers() {
//     _locationTimer = Timer.periodic(Duration(seconds: 5), (_) => _getCurrentLocation());
//     _telegramTimer = Timer.periodic(Duration(seconds: 5), (_) => _checkTelegramUpdates());
//     _expiryTimer = Timer.periodic(Duration(minutes: 1), (_) => _checkBlockExpiry());
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       final location = await _locationService.getLocation();
//       setState(() {
//         _currentLocation = location;
//         _updateUserMarker();
//       });
//       if (_destination != null) _calculateRoute();
//     } catch (e) {
//       print("Location error: $e");
//     }
//   }

//   void _listenToCompass() {
//     FlutterCompass.events?.listen((event) {
//       setState(() => _deviceDirection = event.heading);
//       _updateUserMarker();
//     });
//   }

//   void _updateUserMarker() {
//     if (_currentLocation == null) return;
    
//     _markers.removeWhere((m) => m.child is Icon && (m.child as Icon).color == Colors.blue);
    
//     _markers.add(Marker(
//       point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//       child: Transform.rotate(
//         angle: (_deviceDirection ?? 0) * (pi / 180),
//         child: Icon(Icons.navigation, color: Colors.blue, size: 40),
//       ),
//     ));
//   }

//   Future<void> _searchLocation(String query) async {
//     if (query.isEmpty) return;

//     final response = await http.get(Uri.parse(
//       'https://nominatim.openstreetmap.org/search?q=$query&format=json&accept-language=ar'
//     ));

//     if (response.statusCode != 200) return;

//     final data = json.decode(response.body);
//     if (data.isEmpty) return;

//     setState(() {
//       _destination = LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
//       _markers.removeWhere((m) => m.child is Icon && (m.child as Icon).color == Colors.red);
//       _markers.add(Marker(
//         point: _destination!,
//         child: Icon(Icons.location_on, color: Colors.red, size: 40),
//       ));
//       _mapController.move(_destination!, 15);
//     });

//     _calculateRoute();
//   }

//   Future<void> _calculateRoute() async {
//     if (_currentLocation == null || _destination == null) return;

//     final start = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
//     final avoid = _blockedRoads.isNotEmpty 
//       ? '&options={"avoid_locations":[[${_blockedRoads.map((p) => '${p.longitude},${p.latitude}').join('],[')}]]}'
//       : '';

//     final response = await http.get(Uri.parse(
//       'https://api.openrouteservice.org/v2/directions/driving-car?'
//       'api_key=5b3ce3597851110001cf62485bf8e58a124640b1bc61ce2b4825433e'
//       '&start=${start.longitude},${start.latitude}'
//       '&end=${_destination!.longitude},${_destination!.latitude}'
//       '$avoid'
//     ));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['features'].isNotEmpty) {
//         setState(() {
//           final coords = data['features'][0]['geometry']['coordinates'] as List;
//           _routePoints = coords.map<LatLng>((c) => LatLng(c[1] as double, c[0] as double)).toList();
//           if (_isRouteBlocked) {
//             _alternativeRoute = List.from(_routePoints);
//           }
//         });
//       }
//     }
//   }

//   List<String> _extractLocationNames(String message) {
//     final RegExp locationRegex = RegExp(
//       r'\b(حوارة|نابلس|رام الله|طولكرم|جنين|قلقيلية|بيت لحم|الخليل|أريحا|سلفيت|طوباس|'
//       r'الحرم القدسي|شارع المدارس|شارع النجمة|شارع رشيد|شارع عمان|شارع يافا|'
//       r'ميدان المنارة|دوار الشهداء|مفرق بيتونيا|مفرق الجلزون|الطريق الرئيسي|'
//       r'طريق نابلس-طولكرم|طريق رام الله-القدس)\b',
//       caseSensitive: false,
//     );
//     return locationRegex.allMatches(message).map((match) => match.group(0)!).toList();
//   }

//   Future<LatLng?> _getCoordinatesFromName(String locationName) async {
//     try {
//       final response = await http.get(Uri.parse(
//         'https://nominatim.openstreetmap.org/search?q=$locationName, فلسطين&format=json&accept-language=ar'
//       ));
      
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data.isNotEmpty) {
//           return LatLng(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
//         }
//       }
//     } catch (e) {
//       print("Geocoding error: $e");
//     }
//     return null;
//   }

//   Future<void> _checkTelegramUpdates() async {
//     if (_isLoading) return;
    
//     setState(() => _isLoading = true);
    
//     try {
//       final response = await http.get(Uri.parse(
//         'https://api.telegram.org/bot7608922442:AAHaWNXgfJFxgPBi2VJgdWekfznFIQ-4ZOQ/getUpdates?chat_id=-1002436928564'
//       ));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         for (var update in data['result']) {
//           if (update['message'] != null) {
//             _processTelegramMessage(update['message']['text']);
//           }
//         }
//       }
//     } catch (e) {
//       print("Telegram error: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//  void _processTelegramMessage(String message) async {
//   if (_isBlockedMessage(message)) {
//     _handleBlockedRoad(message);
//   } else if (_isUnblockedMessage(message)) {
//     _handleUnblockedRoad(message);
//   }
// }

// Future<void> _handleBlockedRoad(String message) async {
//   final locationNames = _extractLocationNames(message);
  
//   for (final name in locationNames) {
//     final LatLng? location = await _getCoordinatesFromName(name);
//     if (location != null && !_blockedRoads.contains(location)) {
//       setState(() {
//         _isRouteBlocked = true;
//         _blockedRoads.add(location);
//         _blockedRoadsExpiry[location] = DateTime.now().add(Duration(hours: 2));
//         // إضافة خط أحمر على الخريطة (بطول 1 متر)
//         _addRedLineOnMap(location);
//       });
//       _showAlert('تحذير', 'تم إغلاق طريق: $name\n$message');
//       _calculateRoute();
//     }
//   }
// }

// void _addRedLineOnMap(LatLng blockedLocation) {
//   // نضع خطاً أحمر حول الموقع المغلق مع تحديد الطول
//   // هنا نضيف خطًا على الخريطة باستخدام الـ Polyline
//   LatLng newPoint = LatLng(blockedLocation.latitude + 0.00001, blockedLocation.longitude); // تعديل الموقع قليلاً للحصول على خط
//   setState(() {
//     _routePoints.add(blockedLocation);
//     _routePoints.add(newPoint); // إضافة النقطة الثانية بعد التعديل
//   });
// }


//   bool _isBlockedMessage(String message) {
//     final lowerMsg = message.toLowerCase();
//     return _blockedKeywords.any(lowerMsg.contains) && 
//            !_unblockedKeywords.any(lowerMsg.contains) &&
//            (_adminKeywords.any(lowerMsg.contains) || _isOfficialMessage(message));
//   }

//   bool _isUnblockedMessage(String message) {
//     final lowerMsg = message.toLowerCase();
//     return _unblockedKeywords.any(lowerMsg.contains);
//   }

//   bool _isOfficialMessage(String message) {
//     return message.contains('بلدية') || 
//            message.contains('المرور') || 
//            message.contains('الداخلية') ||
//            message.contains('شرطة') ||
//            message.contains('دفاع مدني');
//   }

//   List<LatLng> _createOneMeterSegment(LatLng center) {
//     const distance = 0.00001; // حوالي 1 متر في وحدات الدرجات
//     return [
//       LatLng(center.latitude - distance, center.longitude - distance),
//       LatLng(center.latitude + distance, center.longitude + distance),
//     ];
//   }


//   double _calculateDistance(LatLng p1, LatLng p2) {
//     return sqrt(pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2));
//   }

//   Future<void> _handleUnblockedRoad(String message) async {
//     final locationNames = _extractLocationNames(message);
    
//     for (final name in locationNames) {
//       final LatLng? location = await _getCoordinatesFromName(name);
//       if (location != null) {
//         setState(() {
//           _blockedRoads.removeWhere((point) => 
//             _calculateDistance(point, location) < 0.00002
//           );
//           _blockedRoadsExpiry.removeWhere((point, _) => 
//             _calculateDistance(point, location) < 0.00002
//           );
//           _isRouteBlocked = _blockedRoads.isNotEmpty;
//         });
//         _showAlert('إشعار', 'تم فتح طريق: $name');
//         _calculateRoute();
//       }
//     }
//   }

//   void _checkBlockExpiry() {
//     final now = DateTime.now();
//     bool needsUpdate = false;

//     setState(() {
//       _blockedRoadsExpiry.removeWhere((location, expiry) {
//         if (now.isAfter(expiry)) {
//           _blockedRoads.remove(location);
//           needsUpdate = true;
//           return true;
//         }
//         return false;
//       });
//       _isRouteBlocked = _blockedRoads.isNotEmpty;
//     });

//     if (needsUpdate) _calculateRoute();
//   }

//   void _showAlert(String title, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: Duration(seconds: 5),
//         backgroundColor: title == 'تحذير' ? Colors.orange : Colors.green,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _locationTimer?.cancel();
//     _telegramTimer?.cancel();
//     _expiryTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('حالة الطرق - التكسي الذكي'),
//         actions: [
//           if (_isRouteBlocked)
//             IconButton(
//               icon: Icon(Icons.warning, color: Colors.red),
//               onPressed: () => _showBlockedRoadsDialog(),
//             ),
//           IconButton(
//             icon: _isLoading ? CircularProgressIndicator() : Icon(Icons.refresh),
//             onPressed: _isLoading ? null : _checkTelegramUpdates,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'ابحث عن وجهة...',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.search),
//                     ),
//                     onSubmitted: _searchLocation,
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 FloatingActionButton(
//                   mini: true,
//                   child: Icon(Icons.search),
//                   onPressed: () => _searchLocation(_searchController.text),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _currentLocation == null
//                 ? Center(child: CircularProgressIndicator())
//                 : FlutterMap(
//                     mapController: _mapController,
//                     options: MapOptions(
//                       initialCenter: LatLng(
//                         _currentLocation!.latitude!,
//                         _currentLocation!.longitude!,
//                       ),
//                       initialZoom: 15,
//                     ),
//                     children: [
//                       TileLayer(
//                         urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                         subdomains: ['a', 'b', 'c'],
//                       ),
//                       MarkerLayer(markers: _markers),
//                       PolylineLayer(
//                         polylines: [
//                           if (_routePoints.isNotEmpty)
//                             Polyline(
//                               points: _routePoints,
//                               color: _isRouteBlocked ? Colors.orange : Colors.blue,
//                               strokeWidth: 5,
//                             ),
//                           if (_blockedRoads.isNotEmpty)
//                             Polyline(
//                               points: _blockedRoads,
//                               color: Colors.red,
//                               strokeWidth: 3,
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: 'location',
//             child: Icon(Icons.my_location),
//             onPressed: () {
//               if (_currentLocation != null) {
//                 _mapController.move(
//                   LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//                   15,
//                 );
//               }
//             },
//           ),
//           SizedBox(height: 10),
//           FloatingActionButton(
//             heroTag: 'route',
//             child: Icon(Icons.directions),
//             onPressed: _calculateRoute,
//           ),
//         ],
//       ),
//     );
//   }

//   void _showBlockedRoadsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('الطرق المغلقة'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: _blockedRoads.map((road) => ListTile(
//               leading: Icon(Icons.block, color: Colors.red),
//               title: Text(_getLocationName(road)),
//               subtitle: Text('تنتهي الصلاحية: ${_blockedRoadsExpiry[road]?.toString() ?? 'غير معروف'}'),
//             )).toList(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: Text('حسناً'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getLocationName(LatLng location) {
//     if (location.latitude.toString().contains('32.1535')) return 'حوارة';
//     if (location.latitude.toString().contains('32.2222')) return 'نابلس';
//     return 'موقع (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
//   }
// }