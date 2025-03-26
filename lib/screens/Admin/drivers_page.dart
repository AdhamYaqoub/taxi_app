import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  _DriversPageState createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  List<Map<String, dynamic>> drivers = [
    {
      "name": "أحمد خالد",
      "status": true,
      "rating": 4.8,
      "rides": 320,
      "type": "محترف"
    },
    {
      "name": "سامي عادل",
      "status": false,
      "rating": 4.2,
      "rides": 210,
      "type": "جديد"
    },
    {
      "name": "مروان يوسف",
      "status": true,
      "rating": 4.9,
      "rides": 450,
      "type": "VIP"
    },
  ];

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
        title:
            Text(AppLocalizations.of(context).translate('drivers_management')),
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
              child: ListView.builder(
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
