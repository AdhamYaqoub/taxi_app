import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

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
