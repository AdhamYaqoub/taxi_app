import 'package:flutter/material.dart';
import 'package:taxi_app/screens/Manegar/details.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:taxi_app/language/localization.dart'; // استيراد AppLocalizations

class OfficeManagerPage extends StatefulWidget {
  final String officeId;

  const OfficeManagerPage({super.key, required this.officeId});

  @override
  _OfficeManagerPageState createState() => _OfficeManagerPageState();
}

class _OfficeManagerPageState extends State<OfficeManagerPage> {
  List<Map<String, String>> drivers = [
    {"name": "أحمد علي", "phone": "0599123456", "status": "نشط", "trips": "120", "earnings": "\$450"},
    {"name": "خالد يوسف", "phone": "0599876543", "status": "غير متصل", "trips": "80", "earnings": "\$300"},
    {"name": "محمد سعيد", "phone": "0591234567", "status": "مشغول", "trips": "200", "earnings": "\$780"},
  ];

  String searchQuery = "";
  String selectedFilter = "الكل";

  void removeDriver(int index) {
    setState(() {
      drivers.removeAt(index);
    });
  }

  void editDriver(int index) {
    print("✏ تعديل بيانات السائق: ${drivers[index]['name']}");
  }

  void addDriver() {
    print("➕ إضافة سائق جديد");
  }

  List<Map<String, String>> getFilteredDrivers() {
    return drivers.where((driver) {
      bool matchesSearch = driver["name"]!.contains(searchQuery) || driver["phone"]!.contains(searchQuery);
      bool matchesFilter = selectedFilter == "الكل" || driver["status"] == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

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
    // استخدام الترجمة من AppLocalizations
    String searchLabel = AppLocalizations.of(context).translate('search_driver');
    String noDriversText = AppLocalizations.of(context).translate('no_drivers');
    String filterLabel = AppLocalizations.of(context).translate('filter');
    String editLabel = AppLocalizations.of(context).translate('edit');
    String removeLabel = AppLocalizations.of(context).translate('remove');

    List<Map<String, String>> filteredDrivers = getFilteredDrivers();

    return Scaffold(
      appBar: CustomAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600; // شاشة كبيرة
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 🔍 مربع البحث
                TextField(
                  decoration: InputDecoration(
                    labelText: searchLabel,  // النص المترجم هنا
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 🔄 فلترة السائقين
                DropdownButton<String>(
                  value: selectedFilter,
                  items: ["الكل", "نشط", "غير متصل", "مشغول"].map((status) {
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

                // 📋 قائمة السائقين
                Expanded(
                  child: filteredDrivers.isEmpty
                      ? Center(child: Text(noDriversText)) // النص المترجم هنا
                      : ListView.builder(
                          itemCount: filteredDrivers.length,
                          itemBuilder: (context, index) {
                            var driver = filteredDrivers[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.yellow.shade700,
                                  child: Text(driver['name']![0], style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(driver['name']!),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("📞 ${driver['phone']}"),
                                    Text("🚗 عدد الرحلات: ${driver['trips']}"),
                                    Text("💰 الأرباح: ${driver['earnings']}"),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      editDriver(index);
                                    } else if (value == 'remove') {
                                      removeDriver(index);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(value: 'edit', child: Text(editLabel)), // النص المترجم هنا
                                    PopupMenuItem(value: 'remove', child: Text(removeLabel)), // النص المترجم هنا
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverDetailsPage(driver: driver),
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
          );
        },
      ),
    );
  }
}
