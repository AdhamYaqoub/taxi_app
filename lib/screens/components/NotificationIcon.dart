import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/notification_provider.dart';
import 'package:taxi_app/screens/User/mytrip.dart';

class NotificationIcon extends StatefulWidget {
  const NotificationIcon({super.key});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.bell),
          onPressed: () => _showNotifications(context),
        ),
        if (notificationProvider.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                notificationProvider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotifications(BuildContext context) async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);
    await provider.fetchAllNotifications(14); // استبدل 13 بالـ userId الحقيقي

    // عرض الإشعارات في BottomSheet
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإشعارات',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    child: const Text('تم'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return ListTile(
                    leading: Icon(
                      LucideIcons.bell,
                      color: notification['status'] == 'unread'
                          ? Colors.red
                          : Colors.grey,
                    ),
                    title: Text(notification['title']),
                    subtitle: Text(notification['message']),
                    trailing: notification['status'] == 'unread'
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
                    onTap: () async {
                      // 1. تحديث حالة الإشعار كمقروء
                      if (notification['status'] == 'unread') {
                        await provider
                            .markAsRead(notification['notificationId']);
                      }

                      // 2. إغلاق صفحة الإشعارات
                      Navigator.pop(context);

                      // 3. الانتقال إلى صفحة Trip History
                      if (mounted) {
                        // تأكد أن الـ widget ما زال موجودًا في الشجرة
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ClientTripsPage(
                                userId: 14), // استبدل 13 بالـ userId الحقيقي
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
