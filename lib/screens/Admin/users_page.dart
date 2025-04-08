import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:taxi_app/services/UserDetailPage.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // جلب بيانات المستخدمين من API
  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/users'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          // تصفية المستخدمين الذين لديهم "role" يساوي "User"
          users = data
              .where((user) => user["role"] == "User") // التصفية هنا
              .map((user) => {
                "name": user["fullName"] ?? 'اسم غير موجود',
                "status": user["isAvailable"] ?? false,
                "rides": user["earnings"] ?? 0,
                "type": user["role"] ?? 'غير محدد',
              })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('فشل في تحميل المستخدمين');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error: $error");
    }
  }

  // تغيير حالة المستخدم
  void toggleUserStatus(int index) {
    setState(() {
      users[index]['status'] = !users[index]['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('users_management')),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('users_list'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? Center(child: Text('لا توجد بيانات للمستخدمين'))
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            var user = users[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Icon(LucideIcons.user, color: Colors.black),
                                title: Text(user["name"],
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    "${AppLocalizations.of(context).translate('user_type')}: ${user['type']} • ${AppLocalizations.of(context).translate('rides_count')}: ${user['rides']}"),
                                trailing: Switch(
                                  value: user['status'],
                                  onChanged: (value) => toggleUserStatus(index),
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                ),
                                onTap: () {
                                  // الانتقال إلى صفحة تفاصيل المستخدم عند النقر
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserDetailPage(user: user),
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

