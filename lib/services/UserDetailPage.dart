import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(user["name"], style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المستخدم
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(LucideIcons.user, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            
            // اسم المستخدم
            Text(
              user["name"],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            
            // حالة المستخدم
            _buildDetailRow("الحالة", user["status"] ? "متاح" : "غير متاح", theme),
            _buildDetailRow("النوع", user["type"], theme),
            _buildDetailRow("الرحلات", "${user["rides"]}", theme),
            const SizedBox(height: 20),
            
            // تفاصيل إضافية (مثل تاريخ الانضمام أو الموقع)
            Text(
              "تفاصيل إضافية",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 15),
            _buildDetailRow("تاريخ الانضمام", user["join_date"] ?? "غير معروف", theme),
            _buildDetailRow("الموقع", user["location"] ?? "غير محدد", theme),
            const SizedBox(height: 30),
            
            // أزرار إضافية
            _buildActionButton("تعديل التفاصيل", theme),
            _buildActionButton("حذف المستخدم", theme, isDelete: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16, color: theme.colorScheme.onBackground))),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, ThemeData theme, {bool isDelete = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          // Define your action here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDelete ? Colors.red : theme.colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
