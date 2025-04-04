// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:taxi_app/models/trip.dart'; // نستخدم نموذج Trip بدلاً من Earning

// class EarningsApi {
//   static const String _baseUrl = 'http://localhost:5000/api';

//   static Future<double> getTotalEarnings(int driverId) async {
//     final response = await http.get(
//       Uri.parse('$_baseUrl/trips/earnings/total/$driverId'),
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body)['totalEarnings'];
//     } else {
//       throw Exception('Failed to load total earnings');
//     }
//   }

//   static Future<List<Trip>> getEarningsDetails(int driverId) async {
//     final response = await http.get(
//       Uri.parse('$_baseUrl/trips/earnings/details/$driverId'),
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['trips'];
//       return data.map((json) => Trip.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load earnings details');
//     }
//   }
// }
