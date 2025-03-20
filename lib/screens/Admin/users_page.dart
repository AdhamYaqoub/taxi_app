import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> users = [
    {"name": "نور الدين علي", "status": true, "rides": 120, "type": "VIP"},
    {"name": "أمل محمود", "status": false, "rides": 45, "type": "عادي"},
    {"name": "خالد إبراهيم", "status": true, "rides": 230, "type": "مميز"},
  ];

  void toggleUserStatus(int index) {
    setState(() {
      users[index]['status'] = !users[index]['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text("إدارة المستخدمين 👥"),
        backgroundColor: Colors.yellow.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "قائمة المستخدمين",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
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
                      title: Text(user["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("التصنيف: ${user['type']} • عدد الرحلات: ${user['rides']}"),
                      trailing: Switch(
                        value: user['status'],
                        onChanged: (value) => toggleUserStatus(index),
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
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
