import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(MaterialApp(
    title: 'تطبيق التكسي الذكي',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'Tajawal',
    ),
    home: MapScreen(),
  ));
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Location _locationService = Location();
  final Completer<GoogleMapController> _mapController = Completer();
  
  LocationData? _currentLocation;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  String _distanceText = '';
  String _durationText = '';
  Timer? _telegramTimer;
  Map<String, Polyline> _blockedRoads = {};
  Set<Polygon> _polygons = {};
  Map<String, String> _blockedRoadsMessages = {};

  // مناطق معروفة وإحداثياتها
  final Map<String, List<LatLng>> _knownAreas = {
    'دير شرف': [
      LatLng(32.225, 35.225),
      LatLng(32.230, 35.230),
      LatLng(32.235, 35.235),
    ],
    'حوارة': [
      LatLng(32.1535, 35.2587),
      LatLng(32.155, 35.260),
      LatLng(32.157, 35.262),
    ],
    'نابلس': [
      LatLng(32.2222, 35.2597),
      LatLng(32.225, 35.262),
      LatLng(32.228, 35.265),
    ],
    'رام الله': [
      LatLng(31.9029, 35.2062),
      LatLng(31.907, 35.210),
      LatLng(31.912, 35.215),
    ],
    'القدس': [
      LatLng(31.7767, 35.2345),
      LatLng(31.780, 35.238),
      LatLng(31.785, 35.242),
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _startTelegramUpdates();
  }

  Future<void> _initializeApp() async {
    await _getCurrentLocation();
  }

  void _startTelegramUpdates() {
    _telegramTimer = Timer.periodic(Duration(seconds: 30), (_) => _checkTelegramUpdates());
  }

  Future<void> _checkTelegramUpdates() async {
    try {
      final response = await http.get(Uri.parse(
        'https://api.telegram.org/7608922442:AAHaWNXgfJFxgPBi2VJgdWekfznFIQ-4ZOQ/getUpdates'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        for (var update in data['result']) {
          if (update['message'] != null) {
            _processTelegramMessage(update['message']['text']);
          }
        }
      }
    } catch (e) {
      print("Telegram error: $e");
    }
  }

  void _processTelegramMessage(String message) {
    final lowerMsg = message.toLowerCase();
    
    // تحقق من إغلاق الطرق
    if (lowerMsg.contains('مسكرة') || lowerMsg.contains('مغلقة') || 
        lowerMsg.contains('إغلاق') || lowerMsg.contains('تحويلة')) {
      _processRoadClosure(message);
    }
    // تحقق من فتح الطرق
    else if (lowerMsg.contains('فتحت') || lowerMsg.contains('انفتحت') || 
             lowerMsg.contains('فتح') || lowerMsg.contains('مفتوحة')) {
      _processRoadOpening(message);
    }
  }

  void _processRoadClosure(String message) {
    for (var area in _knownAreas.keys) {
      if (message.toLowerCase().contains(area.toLowerCase())) {
        _blockRoad(area, message);
        break;
      }
    }
  }

  void _processRoadOpening(String message) {
    for (var area in _knownAreas.keys) {
      if (message.toLowerCase().contains(area.toLowerCase())) {
        _openRoad(area, message);
        break;
      }
    }
  }

  void _blockRoad(String areaName, String message) {
    if (!_knownAreas.containsKey(areaName)) return;

    final areaId = areaName.replaceAll(' ', '_');
    
    setState(() {
      _blockedRoads[areaId] = Polyline(
        polylineId: PolylineId(areaId),
        points: _knownAreas[areaName]!,
        color: Colors.red,
        width: 8,
      );

      _polygons.add(Polygon(
        polygonId: PolygonId(areaId),
        points: _knownAreas[areaName]!,
        fillColor: Colors.red.withOpacity(0.3),
        strokeColor: Colors.red,
        strokeWidth: 2,
      ));

      _blockedRoadsMessages[areaId] = message;
    });

    _showAlert('إغلاق طريق', 'تم إغلاق $areaName: ${_truncateMessage(message)}');
    
    if (_destination != null) {
      _calculateRoute();
    }
  }

  void _openRoad(String areaName, String message) {
    final areaId = areaName.replaceAll(' ', '_');
    
    setState(() {
      _blockedRoads.remove(areaId);
      _polygons.removeWhere((polygon) => polygon.polygonId.value == areaId);
      _blockedRoadsMessages.remove(areaId);
    });

    _showAlert('فتح طريق', 'تم فتح $areaName: ${_truncateMessage(message)}');
    
    if (_destination != null) {
      _calculateRoute();
    }
  }

  String _truncateMessage(String message, {int maxLength = 50}) {
    return message.length > maxLength ? message.substring(0, maxLength) + '...' : message;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getLocation();
      setState(() {
        _currentLocation = location;
        _updateUserMarker();
      });
    } catch (e) {
      print("Location error: $e");
    }
  }

  void _updateUserMarker() {
    if (_currentLocation == null) return;
    
    _markers.removeWhere((m) => m.markerId.value == 'user_location');
    
    _markers.add(Marker(
      markerId: MarkerId('user_location'),
      position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: 'موقعك الحالي'),
    ));
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _distanceText = '';
      _durationText = '';
    });

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?'
        'query=$encodedQuery'
        '&key=AIzaSyAiI9plG4Q_kvQ5n6YLSWVY0867lLlOywc'
        '&language=ar'
        '&region=ps'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            _destination = LatLng(
              data['results'][0]['geometry']['location']['lat'],
              data['results'][0]['geometry']['location']['lng'],
            );
            
            _markers.removeWhere((m) => m.markerId.value == 'destination');
            _markers.add(Marker(
              markerId: MarkerId('destination'),
              position: _destination!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: data['results'][0]['name'] ?? 'الوجهة',
                snippet: 'اضغط مطولاً لإضافة نقطة',
              ),
            ));
          });

          final GoogleMapController controller = await _mapController.future;
          controller.animateCamera(CameraUpdate.newLatLngZoom(_destination!, 15));
          await _calculateRoute();
        } else {
          _showAlert('خطأ', 'لم يتم العثور على نتائج للبحث');
        }
      } else {
        _showAlert('خطأ', 'فشل في الحصول على النتائج');
      }
    } catch (e) {
      print('Search error: $e');
      _showAlert('خطأ', 'حدث خطأ في الاتصال بالإنترنت');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateRoute() async {
    if (_currentLocation == null || _destination == null) return;

    setState(() => _isLoading = true);

    final start = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    
    try {
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${start.latitude},${start.longitude}'
        '&destination=${_destination!.latitude},${_destination!.longitude}'
        '&mode=driving'
        '&key=AIzaSyAiI9plG4Q_kvQ5n6YLSWVY0867lLlOywc'
        '&language=ar'
        '&alternatives=true'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          // اختيار المسار الأفضل مع تجنب المناطق المغلقة
          final bestRoute = _selectBestRoute(data['routes']);
          final leg = bestRoute['legs'][0];
          
          setState(() {
            _distanceText = leg['distance']['text'];
            _durationText = leg['duration']['text'];
            
            _polylines.removeWhere((p) => p.polylineId.value == 'route');
            final points = bestRoute['overview_polyline']['points'];
            _routePoints = _decodePoly(points);
            
            _polylines.add(Polyline(
              polylineId: PolylineId('route'),
              points: _routePoints,
              color: Colors.blue,
              width: 5,
              startCap: Cap.roundCap,
              endCap: Cap.buttCap,
              jointType: JointType.round,
            ));
          });
        } else {
          _showAlert('تحذير', 'لا يوجد مسار متاح بسبب الطرق المغلقة');
        }
      }
    } catch (e) {
      print('Route calculation error: $e');
      _showAlert('خطأ', 'حدث خطأ في حساب المسار');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _selectBestRoute(List<dynamic> routes) {
    // إذا لم تكن هناك طرق مغلقة، نختار أول مسار
    if (_blockedRoads.isEmpty) return routes[0];

    // نحاول إيجاد مسار لا يمر عبر المناطق المغلقة
    for (var route in routes) {
      bool passesThroughBlockedArea = false;
      final points = _decodePoly(route['overview_polyline']['points']);
      
      for (var point in points) {
        for (var blockedArea in _blockedRoads.values) {
          if (_isPointInPolygon(point, blockedArea.points)) {
            passesThroughBlockedArea = true;
            break;
          }
        }
        if (passesThroughBlockedArea) break;
      }
      
      if (!passesThroughBlockedArea) {
        return route;
      }
    }

    // إذا كانت جميع المسارات تمر عبر مناطق مغلقة، نختار المسار الأقصر
    return routes[0];
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    // خوارزمية لفحص إذا كانت النقطة داخل المضلع
    int i, j = polygon.length - 1;
    bool oddNodes = false;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < point.latitude && polygon[j].latitude >= point.latitude) ||
          (polygon[j].latitude < point.latitude && polygon[i].latitude >= point.latitude)) {
        if (polygon[i].longitude + (point.latitude - polygon[i].latitude) /
            (polygon[j].latitude - polygon[i].latitude) *
            (polygon[j].longitude - polygon[i].longitude) < point.longitude) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }

    return oddNodes;
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _launchGoogleMapsNavigation() async {
    if (_currentLocation == null || _destination == null) return;

    if (_blockedRoads.isNotEmpty) {
      final blockedAreas = _blockedRoads.keys.join('، ').replaceAll('_', ' ');
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تحذير: طرق مغلقة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('يوجد طرق مغلقة في: $blockedAreas'),
              SizedBox(height: 10),
              Text('الرسائل:'),
              ..._blockedRoadsMessages.values.map((msg) => 
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('- ${_truncateMessage(msg)}'),
                )),
              SizedBox(height: 10),
              Text('هل تريد المتابعة إلى جوجل مابس؟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('فتح جوجل مابس'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    final String origin = '${_currentLocation!.latitude},${_currentLocation!.longitude}';
    final String destination = '${_destination!.latitude},${_destination!.longitude}';
    
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1'
        '&origin=$origin'
        '&destination=$destination'
        '&travelmode=driving';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      _showAlert('خطأ', 'لا يمكن فتح جوجل مابس');
    }
  }

  void _showAlert(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 5),
        backgroundColor: title.contains('تحذير') ? Colors.orange : Colors.green,
      ),
    );
  }

  void _addCustomMarker(LatLng position) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('custom_${position.latitude}_${position.longitude}'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: 'نقطة مخصصة'),
      ));
    });
  }

  Future<void> _centerMapOnUserLocation() async {
    if (_currentLocation != null) {
      final controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          15,
        ),
      );
    }
  }

  void _refreshMap() {
    setState(() {
      _blockedRoads.clear();
      _polygons.clear();
      _blockedRoadsMessages.clear();
    });
    if (_destination != null) {
      _calculateRoute();
    }
  }

  @override
  void dispose() {
    _telegramTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التكسي الذكي - الخريطة التفاعلية'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshMap,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن وجهة...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: _searchLocation,
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  child: Icon(Icons.search),
                  onPressed: () => _searchLocation(_searchController.text),
                ),
              ],
            ),
          ),
          if (_distanceText.isNotEmpty || _durationText.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('المسافة: $_distanceText'),
                  Text('المدة: $_durationText'),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                _currentLocation == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        onMapCreated: (controller) {
                          _mapController.complete(controller);
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _currentLocation?.latitude ?? 32.2222,
                            _currentLocation?.longitude ?? 35.2597,
                          ),
                          zoom: 15,
                        ),
                        markers: _markers,
                        polylines: Set<Polyline>.from(_polylines)
                          ..addAll(_blockedRoads.values),
                        polygons: _polygons,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        onLongPress: _addCustomMarker,
                      ),
                if (_isLoading)
                  Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'location',
            child: Icon(Icons.my_location),
            onPressed: _centerMapOnUserLocation,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'route',
            child: Icon(Icons.directions),
            onPressed: _calculateRoute,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'navigation',
            child: Icon(Icons.navigation),
            onPressed: _launchGoogleMapsNavigation,
          ),
        ],
      ),
    );
  }
}