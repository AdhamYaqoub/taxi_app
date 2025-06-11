import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/trip.dart';
import 'package:taxi_app/services/trips_api.dart';

class DriverTripsPage extends StatefulWidget {
  const DriverTripsPage({super.key});

  @override
  State<DriverTripsPage> createState() => _DriverTripsPageState();
}

class _DriverTripsPageState extends State<DriverTripsPage> {
  late Future<List<Trip>> _completedTripsFuture;
  late Future<List<Trip>> _inProgressTripsFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() => _isLoading = true);

    _completedTripsFuture = TripsApi.getAllTripsWithStatus(
      status: 'completed',
    ).catchError((error) {
      debugPrint('Error loading completed trips: $error');
      return <Trip>[];
    });

    _inProgressTripsFuture = TripsApi.getAllTripsWithStatus(
      status: 'in_progress',
    ).catchError((error) {
      debugPrint('Error loading in-progress trips: $error');
      return <Trip>[];
    });

    Future.wait([_completedTripsFuture, _inProgressTripsFuture])
        .then((_) => setState(() => _isLoading = false))
        .catchError((error) {
      debugPrint('Error in Future.wait: $error');
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar:
          isDesktop ? null : AppBar(automaticallyImplyLeading: false,
          title: Text(local.translate('my_trips'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadTrips(),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      title: local.translate('in_progress_trips'),
                      icon: LucideIcons.clock,
                    ),
                    const SizedBox(height: 8),
                    _buildTripsList(
                      context,
                      future: _inProgressTripsFuture,
                      emptyMessage: local.translate('no_in_progress_trips'),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      context,
                      title: local.translate('completed_trips'),
                      icon: LucideIcons.checkCircle,
                    ),
                    const SizedBox(height: 8),
                    _buildTripsList(
                      context,
                      future: _completedTripsFuture,
                      emptyMessage: local.translate('no_completed_trips'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required String title, required IconData icon}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTripsList(
    BuildContext context, {
    required Future<List<Trip>> future,
    required String emptyMessage,
  }) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    return FutureBuilder<List<Trip>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(theme, local);
        }

        final trips = snapshot.data ?? [];
        if (trips.isEmpty) {
          return _buildEmptyState(theme, emptyMessage);
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trips.length,
          itemBuilder: (context, index) =>
              _buildTripCard(context, trips[index]),
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final isCompleted = trip.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${local.translate('trip')} #${trip.tripId}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCompleted
                        ? local.translate('completed')
                        : local.translate('in_progress'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCompleted ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTripDetailRow(
              icon: LucideIcons.mapPin,
              label: local.translate('from'),
              value: trip.startLocation.address,
            ),
            _buildTripDetailRow(
              icon: LucideIcons.user,
              label: local.translate('user_name'),
              value: trip.userName.toString(),
            ),
            _buildTripDetailRow(
              icon: LucideIcons.user,
              label: local.translate('driver_name'),
              value: trip.driverName.toString(),
            ),
            _buildTripDetailRow(
              icon: LucideIcons.mapPin,
              label: local.translate('to'),
              value: trip.endLocation.address,
            ),
            _buildTripDetailRow(
              icon: LucideIcons.clock,
              label: isCompleted
                  ? local.translate('completed_on')
                  : local.translate('started_on'),
              value: _formatDateTime(
                isCompleted ? trip.endTime : trip.startTime,
              ),
            ),
            if (isCompleted)
              _buildTripDetailRow(
                icon: LucideIcons.dollarSign,
                label: local.translate('fare'),
                value: "\$${trip.actualFare.toStringAsFixed(2)}",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, AppLocalizations local) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error, color: theme.colorScheme.error, size: 40),
          const SizedBox(height: 16),
          Text(
            local.translate('error_loading_trips'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadTrips,
            child: Text(local.translate('retry')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Center(
      child: Column(
        children: [
          Icon(
            LucideIcons.list,
            size: 40,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(message, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildTripDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '--';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
