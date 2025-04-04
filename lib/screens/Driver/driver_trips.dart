import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/trip.dart';
import 'package:taxi_app/services/trips_api.dart';

class DriverTripsPage extends StatefulWidget {
  final int driverId;

  const DriverTripsPage({
    super.key,
    required this.driverId,
  });

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage> {
  late Future<List<Trip>> _tripsFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tripsFuture = TripsApi.getDriverTrips(widget.driverId);
    _tripsFuture.then((_) => setState(() => _isLoading = false));
  }

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTripList(context),
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

    return FutureBuilder<List<Trip>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final trips = snapshot.data!;

        return ListView.separated(
          itemCount: trips.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final trip = trips[index];

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
                    Text(
                      "${local.translate('distance')}: ${trip.distance} ${local.translate('km')}",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: Text(
                  "\$${trip.earnings.toStringAsFixed(2)}",
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
      },
    );
  }
}
