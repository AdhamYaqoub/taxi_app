import 'package:flutter/material.dart';
import 'package:taxi_app/models/driver.dart';

class DriverDetailPageWeb extends StatelessWidget {
  final Driver driver;

  const DriverDetailPageWeb({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    print(
        "DriverDetailPageWeb: Building driver detail page for ${driver.profileImageUrl}");

    return Scaffold(
      appBar: AppBar(
        title: Text(driver.fullName),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: screenSize.width * 0.7,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(driver.profileImageUrl ??
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrUfiySJr8Org5W-oE2v3_i7VqufglYtSdqw&s'),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      driver.fullName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow("الهاتف", driver.phone),
                    _buildDetailRow("البريد الإلكتروني", driver.email),
                    _buildDetailRow(
                        "التقييم", "${driver.rating.toStringAsFixed(1)} ★"),
                    _buildDetailRow("الأرباح", "${driver.earnings}"),
                    _buildDetailRow("حالة التوفر",
                        driver.isAvailable ? "متاح" : "غير متاح"),
                    _buildDetailRow(
                        "النوع", "سائق"), // يمكنك تغيير هذا حسب الحاجة
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        // تنفيذ الإجراء مثل الاتصال بالسائق
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text("اتصل بالسائق"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
