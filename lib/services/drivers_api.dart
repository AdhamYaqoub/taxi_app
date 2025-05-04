// services/drivers_api.dart (ملف جديد أو إضافة لملف موجود)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taxi_app/models/driver.dart'; // استيراد النموذج

class DriversApi {
  // استبدل هذا بالـ URL الفعلي للـ API الخاص بك
  static const String _baseUrl = 'http://localhost:5000/api';

  static Future<List<Driver>> getAllDrivers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/drivers'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> driversJson = json.decode(response.body);
        return driversJson.map((json) => Driver.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all drivers: $e');
      throw Exception('Failed to load drivers. Please try again later.');
    }
  }

  static Future<List<Driver>> getAvailableDrivers() async {
    // يمكنك إضافة بارامترات مثل الموقع الحالي للمستخدم لجلب أقرب السائقين
    final url = Uri.parse('$_baseUrl/drivers/available'); // مثال لنقطة النهاية

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15)); // إضافة timeout

      if (response.statusCode == 200) {
        final List<dynamic> driversJson = json.decode(response.body);
        // تحويل قائمة الـ JSON إلى قائمة من كائنات Driver
        return driversJson.map((json) => Driver.fromJson(json)).toList();
      } else {
        // التعامل مع رموز الحالة الأخرى (مثل 404, 500)
        throw Exception(
            'Failed to load drivers: Status code ${response.statusCode}');
      }
    } catch (e) {
      // التعامل مع أخطاء الشبكة أو الـ Timeout أو أخطاء التحليل
      print('Error fetching drivers: $e');
      throw Exception('Failed to load drivers. Check your connection.');
    }
  }

  static Future<Driver> getDriverById(int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/drivers/$driverId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Driver.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('فشل في جلب الرحلة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الشبكة: $e');
    }
  }
}
