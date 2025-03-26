import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class DriverTripsPage extends StatelessWidget {
  final String driverName;
  final List<Map<String, String>> trips;

  const DriverTripsPage({
    super.key,
    required this.driverName,
    required this.trips,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final isWeb = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text(
                local.translate('my_trips'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, local.translate('todays_trips')),
            const SizedBox(height: 12),
            Expanded(
              child: _buildTripList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTripList(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return ListView.separated(
      itemCount: trips.isEmpty ? 10 : trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final trip = trips.isEmpty
            ? {
                'id': '${index + 1}',
                'distance': '${(index + 1) * 5}',
                'price': '\$${(index + 1) * 10}'
              }
            : trips[index];

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              LucideIcons.car,
              color: theme.colorScheme.secondary,
            ),
            title: Text(
              "${local.translate('trip')} #${trip['id']}",
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              "${local.translate('distance')}: ${trip['distance']} ${local.translate('km')}",
              style: theme.textTheme.bodySmall,
            ),
            trailing: Text(
              trip['price'] ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        );
      },
    );
  }
}
