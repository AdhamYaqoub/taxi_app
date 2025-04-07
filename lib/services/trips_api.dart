import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taxi_app/models/trip.dart';

class TripsApi {
  static const String _baseUrl = 'http://localhost:5000/api';

  static Future<List<Trip>> getDriverTrips(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trips/driver/$driverId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // تحقق من هيكل الاستجابة
        if (responseData is List) {
          return responseData.map((json) => Trip.fromJson(json)).toList();
        } else if (responseData['trips'] is List) {
          return (responseData['trips'] as List)
              .map((json) => Trip.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Trip>> getRecentTrips(int driverId,
      {int limit = 2}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trips/driver/$driverId/recent'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // تحقق من هيكل الاستجابة
        if (responseData is List) {
          return responseData.map((json) => Trip.fromJson(json)).toList();
        } else if (responseData['trips'] is List) {
          return (responseData['trips'] as List)
              .map((json) => Trip.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load trips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> updateTripStatus(int tripId, String status) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/api/trips/$tripId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update trip status');
    }
  }

  static Future<List<Trip>> getDriverTripsWithStatus(int driverId,
      {String? status}) async {
    try {
      // بناء الرابط مع باراميتر الحالة إذا كان موجود
      String url = '$_baseUrl/trips/driver/$driverId';
      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List) {
          return responseData.map((json) => Trip.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'Failed to load driver trips with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Trip>> getPendingTrips() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trips/pending'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List) {
          return responseData.map((json) => Trip.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load pending trips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Trip>> getTripsByStatus(
      int driverId, String status) async {
    try {
      // المحاولة الأولى: استخدام الباك-إند مع فلتر الحالة
      final response = await http.get(
        Uri.parse('$_baseUrl/trips/driver/$driverId?status=$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          return data.map((json) => Trip.fromJson(json)).toList();
        }
      }

      // الخيار الاحتياطي: الفلترة محلياً
      final allTrips = await getDriverTrips(driverId);
      return allTrips.where((trip) => trip.status == status).toList();
    } catch (e) {
      throw Exception('Failed to load trips: $e');
    }
  }

  static Future<void> acceptTrip(String tripId, int driverId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/accept'),
      body: jsonEncode({'driverId': driverId}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('فشل في قبول الرحلة');
    }
  }

  static Future<void> rejectTrip(String tripId, int driverId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/trips/$tripId/reject'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('فشل في رفض الرحلة');
    }
  }

  // بدء الرحلة
  static Future<void> startTrip(int tripId) async {
    final response =
        await http.post(Uri.parse('$_baseUrl/trips/$tripId/start'));
    if (response.statusCode != 200) {
      throw Exception('فشل في بدء الرحلة');
    }
  }
}
