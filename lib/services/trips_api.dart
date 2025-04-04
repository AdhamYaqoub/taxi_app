import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taxi_app/models/trip.dart';

class TripsApi {
  static const String _baseUrl = 'http://localhost:5000/api';

  // جلب جميع الرحلات للسائق (لصفحة الرحلات الكاملة)
  static Future<List<Trip>> getDriverTrips(int driverId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trips/driver/$driverId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['trips'];
      return data.map((json) => Trip.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trips');
    }
  }

  // جلب الرحلات الحديثة فقط (لصفحة الهوم)
  static Future<List<Trip>> getRecentTrips(int driverId,
      {int limit = 2}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/trips/driver/$driverId/recent?limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['trips'];
      return data.map((json) => Trip.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recent trips');
    }
  }
}
