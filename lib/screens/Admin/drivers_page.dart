import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/driver_detail_page.dart'; // صفحة التفاصيل الجديدة

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<Map<String, dynamic>> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  // جلب بيانات السائقين من API
  Future<void> fetchDrivers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/users')); // تأكد من عنوان API

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          // تصفية السائقين الذين لديهم "role" يساوي "Driver"
          drivers = data
              .where((user) => user["role"] == "Driver") // التصفية هنا
              .map((user) => {
                    "name": user["fullName"] ?? 'اسم غير موجود',
                    "status": user["isAvailable"] ?? false,
                    "rating": user["rating"] ?? 0.0, // يمكنك تعديل هذا حسب المتاح
                    "rides": user["rides"] ?? 0, // أو أي قيمة متاحة في الـ API
                    "type": user["role"] ?? 'غير محدد',
                    "id": user["id"], // تأكد من أن هناك معرف فريد لكل سائق
                    "phone": user["phone"] ?? 'غير متاح',
                    "email": user["email"] ?? 'غير متاح',
                    "location": user["location"] ?? 'غير متاح',
                    // أضف المزيد من البيانات حسب الحاجة
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('فشل في تحميل السائقين');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error: $error");
    }
  }

  // تغيير حالة السائق
  void toggleDriverStatus(int index) {
    setState(() {
      drivers[index]['status'] = !drivers[index]['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('drivers_management')),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('drivers_list'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // عرض المؤشر أثناء التحميل
                  : drivers.isEmpty
                      ? Center(child: Text('لا توجد بيانات للسائقين'))
                      : ListView.builder(
                          itemCount: drivers.length,
                          itemBuilder: (context, index) {
                            var driver = drivers[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Icon(LucideIcons.user, color: Colors.black),
                                title: Text(driver["name"],
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    "${AppLocalizations.of(context).translate('driver_type')}: ${driver['type']} • ${AppLocalizations.of(context).translate('rating')}: ${driver['rating']} ★"),
                                trailing: Switch(
                                  value: driver['status'],
                                  onChanged: (value) => toggleDriverStatus(index),
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                ),
                                onTap: () {
                                  // الانتقال إلى صفحة التفاصيل عند النقر
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverDetailPageWeb(driver: driver),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
