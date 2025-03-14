// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MapScreen(),
//     );
//   }
// }

// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   Set<Marker> markers = Set();
//   Set<Polyline> polylines = Set();
//   static const CameraPosition _kInitialPosition = CameraPosition(
//     target: LatLng(31.9686, 35.9347), // نقطة البداية
//     zoom: 10,
//   );

//   PolylinePoints polylinePoints = PolylinePoints();

//   @override
//   void initState() {
//     super.initState();
//     markers.add(Marker(
//       markerId: MarkerId("start"),
//       position: LatLng(31.9686, 35.9347), // نقطة البداية
//       infoWindow: InfoWindow(title: "نقطة البداية"),
//     ));
//     markers.add(Marker(
//       markerId: MarkerId("end"),
//       position: LatLng(32.0, 35.95), // نقطة النهاية
//       infoWindow: InfoWindow(title: "نقطة النهاية"),
//     ));
//     _getPolyline();
//   }

//   _getPolyline() async {
//     List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
//       'YOUR_API_KEY', // استبدل بـ API Key الخاص بك
//       31.9686, 35.9347,  // نقطة البداية
//       32.0, 35.95,      // نقطة النهاية
//     );

//     if (result.isNotEmpty) {
//       List<LatLng> polylineCoordinates = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
//       setState(() {
//         polylines.add(Polyline(
//           polylineId: PolylineId("route"),
//           points: polylineCoordinates,
//           color: Colors.blue,
//           width: 5,
//         ));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("خرائط فلاتر")),
//       body: GoogleMap(
//         initialCameraPosition: _kInitialPosition,
//         onMapCreated: (controller) {
//           mapController = controller;
//         },
//         markers: markers,
//         polylines: polylines,
//       ),
//     );
//   }
// }
