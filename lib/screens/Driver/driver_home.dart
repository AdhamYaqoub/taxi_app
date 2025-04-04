import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/trip.dart';
import 'package:taxi_app/services/trips_api.dart';

class DriverHomePage extends StatefulWidget {
  final int driverId;

  const DriverHomePage({super.key, required this.driverId});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  late Future<List<Trip>> _recentTripsFuture;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _recentTripsFuture = TripsApi.getRecentTrips(widget.driverId, limit: 2);
    _statsFuture = _fetchDriverStats();
  }

  Future<Map<String, dynamic>> _fetchDriverStats() async {
    // يمكنك استبدال هذا باستدعاء API فعلي
    return {
      'today_trips': 12,
      'today_earnings': 150,
      'ratings': 4.8,
      'active_hours': 8,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.translate('driver_dashboard'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final stats = snapshot.data ??
                  {
                    'today_trips': '--',
                    'today_earnings': '--',
                    'ratings': '--',
                    'active_hours': '--',
                  };

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _buildStats(context, stats),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildRecentTrips(context),
        ],
      ),
    );
  }

  List<Widget> _buildStats(BuildContext context, Map<String, dynamic> stats) {
    final local = AppLocalizations.of(context);

    return [
      _buildStatCard(
        context,
        title: local.translate('today_trips'),
        value: "${stats['today_trips']}",
        icon: LucideIcons.car,
      ),
      _buildStatCard(
        context,
        title: local.translate('today_earnings'),
        value: "\$${stats['today_earnings']}",
        icon: LucideIcons.dollarSign,
      ),
      _buildStatCard(
        context,
        title: local.translate('ratings'),
        value: "${stats['ratings']}",
        icon: LucideIcons.star,
      ),
      _buildStatCard(
        context,
        title: local.translate('active_hours'),
        value: "${stats['active_hours']}h",
        icon: LucideIcons.clock,
      ),
    ];
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrips(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.translate('recent_trips'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Trip>>(
              future: _recentTripsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final trips = snapshot.data ?? [];

                if (trips.isEmpty) {
                  return Text(local.translate('no_recent_trips'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trips.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: theme.dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return ListTile(
                      leading: Icon(
                        LucideIcons.car,
                        color: theme.colorScheme.secondary,
                      ),
                      title: Text(
                        "${local.translate('trip')} #${trip.tripId}",
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${local.translate('from')}: ${trip.startLocation}",
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            "${local.translate('to')}: ${trip.endLocation}",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Text(
                        "\$${trip.earnings.toStringAsFixed(2)}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
