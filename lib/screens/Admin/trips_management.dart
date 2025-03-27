import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class TripsManagementPage extends StatelessWidget {
  const TripsManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(AppLocalizations.of(context).translate('trips_management')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                AppLocalizations.of(context).translate('ongoing_trips')),
            _buildTripList(),
            const SizedBox(height: 20),
            _buildSectionTitle(
                AppLocalizations.of(context).translate('completed_trips')),
            _buildTripList(isOngoing: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTripList({bool isOngoing = true}) {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                isOngoing ? LucideIcons.car : LucideIcons.checkCircle,
                color: isOngoing ? Colors.blue : Colors.green,
              ),
              title: Text(
                  AppLocalizations.of(context).translate('trip_in_progress')),
              subtitle: Text(
                isOngoing
                    ? AppLocalizations.of(context).translate('trip_in_progress')
                    : AppLocalizations.of(context).translate('trip_completed'),
              ),
              trailing: isOngoing
                  ? IconButton(
                      icon: const Icon(LucideIcons.xCircle, color: Colors.red),
                      onPressed: () {
                        // وظيفة إلغاء الرحلة
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
