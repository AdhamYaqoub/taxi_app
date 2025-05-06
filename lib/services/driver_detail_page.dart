import 'package:flutter/material.dart';

class DriverDetailPageWeb extends StatelessWidget {
  final Map<String, dynamic> driver;

  const DriverDetailPageWeb({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(driver["name"] ?? "غير معروف"),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: SingleChildScrollView(  // إضافة ScrollView لجعل المحتوى قابل للتنقل
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: screenSize.width * 0.7, // تحديد العرض بشكل متجاوب للشاشات الكبيرة
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // صورة السائق
                    CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(driver["imageUrl"] ?? 'default_image_url_here'),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 20),

                    // اسم السائق
                    Text(
                      driver["name"] ?? "غير معروف",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // تفاصيل السائق
                    _buildDetailRow("الهاتف", driver["phone"] ?? "غير متوفر"),
                    _buildDetailRow("البريد الإلكتروني", driver["email"] ?? "غير متوفر"),
                    _buildDetailRow("الموقع", driver["location"] ?? "غير محدد"),
                    _buildDetailRow("التقييم", "${driver["rating"] ?? 'N/A'} ★"),
                    _buildDetailRow("عدد الرحلات", "${driver["rides"] ?? 0}"),
                    _buildDetailRow("حالة التوفر", driver["status"] ? "متاح" : "غير متاح"),
                    _buildDetailRow("النوع", driver["type"] ?? "غير محدد"),

                    const SizedBox(height: 20),

                    // زر الإجراء للتواصل مع السائق
                    ElevatedButton.icon(
                      onPressed: () {
                        // تنفيذ الإجراء مثل الاتصال بالسائق
                      },
                      icon: Icon(Icons.phone),
                      label: Text("اتصل بالسائق"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 18),
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

  // دالة لبناء سطر التفاصيل
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black54),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
