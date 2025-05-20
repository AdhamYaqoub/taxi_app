import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../services/driver_detail_page.dart'; // صفحة التفاصيل الجديدة
import 'chat.dart'; // إضافة استيراد صفحة الشات

class OfficeManagerPage extends StatefulWidget {
  final String officeId;

  const OfficeManagerPage({super.key, required this.officeId});

  @override
  _OfficeManagerPageState createState() => _OfficeManagerPageState();
}

class _OfficeManagerPageState extends State<OfficeManagerPage> {
  List<Map<String, dynamic>> drivers = [];
  String searchQuery = "";
  String selectedFilter = "الكل";
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
          drivers = data
              .where((user) => user["role"] == "Driver") // تصفية السائقين حسب الدور
              .map((user) => {
                    "name": user["fullName"] ?? 'اسم غير موجود',
                    "status": user["isAvailable"] ?? false,
                    "rating": user["rating"] ?? 0.0, // يمكنك تعديل هذا حسب المتاح
                    "rides": user["rides"] ?? 0, // أو أي قيمة متاحة في الـ API
                    "type": user["role"] ?? 'غير محدد',
                    "id": user["userId"], // تأكد من أن هناك معرف فريد لكل سائق
                    "phone": user["phone"] ?? 'غير متاح',
                    "email": user["email"] ?? 'غير متاح',
                    "location": user["location"] ?? 'غير متاح',
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

  // دالة للبحث والتصفية حسب الحالة
  List<Map<String, dynamic>> getFilteredDrivers() {
    return drivers.where((driver) {
      bool matchesSearch = driver["name"].toString().contains(searchQuery) ||
                           driver["phone"].toString().contains(searchQuery);
      bool matchesFilter = selectedFilter == "الكل" || (driver["status"] ? "نشط" : "غير متصل") == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  // الاتصال بالسائق
  void _callDriver(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("❌ لا يمكن إجراء المكالمة");
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    List<Map<String, dynamic>> filteredDrivers = getFilteredDrivers();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('drivers_management')),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(  // محاذاة كل المحتوى في الوسط
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,  // محاذاة العناصر في المنتصف
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "🔍 بحث عن سائق",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedFilter,
                items: ["الكل", "نشط", "غير متصل"].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredDrivers.isEmpty
                        ? const Center(child: Text("لا يوجد سائقون"))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              // إذا كانت الشاشة صغيرة، استخدم قائمة
                              if (constraints.maxWidth < 600) {
                                return ListView.builder(
                                  itemCount: filteredDrivers.length,
                                  itemBuilder: (context, index) {
                                    var driver = filteredDrivers[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(driver['name'].toString()),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("📞 ${driver['phone']}"),
                                            Text("🚗 رحلات: ${driver['rides']}"),
                                            Text("💰 أرباح: ${driver['earnings']}"),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.phone, color: Colors.green),
                                          onPressed: () => _callDriver(driver['phone'].toString()),
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
                                );
                              } else {
                                // إذا كانت الشاشة كبيرة، استخدم جدول
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text("الاسم")),
                                      DataColumn(label: Text("الهاتف")),
                                      DataColumn(label: Text("الحالة")),
                                      DataColumn(label: Text("الرحلات")),
                                      DataColumn(label: Text("تفاصيل")),
                                      DataColumn(label: Text("اتصال")),
                                      DataColumn(label: Text("شات")),
                                    ],
                                    rows: filteredDrivers.map((driver) {
                                      return DataRow(
                                        cells: [
                                          DataCell(Text(driver['name'].toString())),
                                          DataCell(Text(driver['phone'].toString())),
                                          DataCell(Text(driver["status"] ? "نشط" : "غير متصل")),
                                          DataCell(Text(driver['rides'].toString())),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.info, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DriverDetailPageWeb(driver: driver),
                                                ),
                                              );
                                            },
                                          )),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.phone, color: Colors.green),
                                            onPressed: () => _callDriver(driver['phone'].toString()),
                                          )),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.chat, color: Colors.blue),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ChatScreen(
                                                    userId: widget.officeId,
                                                    userType: 'admin',
                                                    selectedDriverId: driver['id'].toString(),
                                                  ),
                                                ),
                                              );
                                            },
                                          )),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                );
                              }
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
