import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class MyTripsPage extends StatelessWidget {
  const MyTripsPage({super.key});

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
                local.translate('my_trips_title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                (isWeb
                    ? 0
                    : kToolbarHeight + MediaQuery.of(context).padding.top),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ongoing Trips Section
              Text(
                local.translate('ongoing_trips'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 16),

              // Example of ongoing trips
              _buildTripCard(
                context,
                destination: "${local.translate('trip_to')} X",
                time: "12:30 PM",
                status: local.translate('in_progress'),
                statusColor: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildTripCard(
                context,
                destination: "${local.translate('trip_to')} Y",
                time: "02:00 PM",
                status: local.translate('in_progress'),
                statusColor: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Past Trips Section
              Text(
                local.translate('past_trips'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 16),

              // Example of past trips
              _buildTripCard(
                context,
                destination: "${local.translate('trip_to')} Z",
                time: "10:00 AM",
                status: local.translate('completed'),
                statusColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildTripCard(
                context,
                destination: "${local.translate('trip_to')} W",
                time: "08:30 AM",
                status: local.translate('completed'),
                statusColor: Colors.green,
              ),
              const SizedBox(height: 16),

              // Handle Web and Mobile Responsiveness
              if (isWeb) ...[
                SizedBox(
                  height: 200, // Fixed height for web view
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTripCard(
                          context,
                          destination: "${local.translate('trip_to')} X",
                          time: "12:30 PM",
                          status: local.translate('in_progress'),
                          statusColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTripCard(
                          context,
                          destination: "${local.translate('trip_to')} Y",
                          time: "02:00 PM",
                          status: local.translate('in_progress'),
                          statusColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context, {
    required String destination,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              destination,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${local.translate('time')}: $time",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    LucideIcons.arrowRight,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    // Navigate to trip details
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
