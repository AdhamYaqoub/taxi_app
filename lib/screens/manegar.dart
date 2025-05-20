import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/driver.dart';
import 'package:taxi_app/services/drivers_api.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/driver_detail_page.dart'; // صفحة التفاصيل الجديدة
import 'chat.dart'; // إضافة استيراد صفحة الشات
import '../../services/driver_detail_page.dart';

class OfficeManagerPage extends StatefulWidget {
  final String officeId;

  const OfficeManagerPage({super.key, required this.officeId});

  @override
  _OfficeManagerPageState createState() => _OfficeManagerPageState();
}

class _OfficeManagerPageState extends State<OfficeManagerPage> {
  List<Driver> drivers = [];
  String searchQuery = "";
  String selectedFilter = "الكل";
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      final driversList = await DriversApi.getAllDrivers();
      setState(() {
        drivers = driversList;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _toggleDriverStatus(Driver driver) async {
    try {
      // هنا يمكنك إضافة استدعاء API لتغيير حالة السائق إذا كان لديك endpoint
      // مثال: await DriversApi.updateDriverStatus(driver.userId, !driver.isAvailable);

      setState(() {
        driver.isAvailable = !driver.isAvailable;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(driver.isAvailable
              ? 'تم تفعيل السائق ${driver.fullName}'
              : 'تم إيقاف السائق ${driver.fullName}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحديث حالة السائق: $e')),
      );
    }
  }

  List<Driver> getFilteredDrivers() {
    return drivers.where((driver) {
      bool matchesSearch =
          driver.fullName.toLowerCase().contains(searchQuery.toLowerCase()) ||
              driver.phone.contains(searchQuery);
      bool matchesFilter = selectedFilter == "الكل" ||
          (driver.isAvailable ? "نشط" : "غير متصل") == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _callDriver(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن إجراء المكالمة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final filteredDrivers = getFilteredDrivers();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(local.translate('drivers_management')),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrivers,
            tooltip: local.translate('refresh'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: local.translate('search_driver'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  items: ["الكل", "نشط", "غير متصل"].map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedFilter = value!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
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

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredDrivers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_car, size: 50),
                              const SizedBox(height: 16),
                              Text(local.translate('no_drivers_found')),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return _buildMobileList(
                                  filteredDrivers, theme, local);
                            } else {
                              return _buildDesktopTable(
                                  filteredDrivers, theme, local);
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(
      List<Driver> drivers, ThemeData theme, AppLocalizations local) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(driver.fullName.substring(0, 1)),
            ),
            title: Text(driver.fullName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${local.translate('phone')}: ${driver.phone}"),
                Text(
                    "${local.translate('status')}: ${driver.isAvailable ? local.translate('active') : local.translate('inactive')}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _callDriver(driver.phone),
                ),
                Switch(
                  value: driver.isAvailable,
                  onChanged: (value) => _toggleDriverStatus(driver),
                  activeColor: Colors.green,
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverDetailPageWeb(driver: driver),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
      List<Driver> drivers, ThemeData theme, AppLocalizations local) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(local.translate('name'))),
          DataColumn(label: Text(local.translate('phone'))),
          DataColumn(label: Text(local.translate('status'))),
          DataColumn(label: Text(local.translate('details'))),
          DataColumn(label: Text(local.translate('call'))),
          DataColumn(label: Text(local.translate('status_change'))),
        ],
        rows: drivers.map((driver) {
          return DataRow(
            cells: [
              DataCell(Text(driver.fullName)),
              DataCell(Text(driver.phone)),
              DataCell(
                Chip(
                  label: Text(
                    driver.isAvailable
                        ? local.translate('active')
                        : local.translate('inactive'),
                    style: TextStyle(
                      color: driver.isAvailable ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor:
                      driver.isAvailable ? Colors.green : Colors.grey[300],
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.blue),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverDetailPageWeb(driver: driver),
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _callDriver(driver.phone),
                ),
              ),
              DataCell(
                Switch(
                  value: driver.isAvailable,
                  onChanged: (value) => _toggleDriverStatus(driver),
                  activeColor: Colors.green,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
