import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/driver.dart';
import 'package:taxi_app/models/trip.dart';
import 'package:taxi_app/services/drivers_api.dart';
import 'package:taxi_app/services/trips_api.dart';

class DriverHomePage extends StatefulWidget {
  final int driverId;

  const DriverHomePage({super.key, required this.driverId});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  late Future<List<Trip>> _recentTripsFuture;
  late Future<Driver> _driverInfoFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _driverInfoFuture = DriversApi.getDriverById(widget.driverId);

      _recentTripsFuture = TripsApi.getRecentTrips(widget.driverId)
          .then((trips) =>
              trips.where((trip) => trip.status == 'completed').toList())
          .catchError((error) {
        debugPrint('Error loading recent trips: $error');
        return <Trip>[];
      });
    });
  }

  Widget _buildDriverProfile(BuildContext context, Driver driver) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias, // مثل الكود الثاني
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isDesktop ? 30 : 25,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: (driver.profileImageUrl != null &&
                          driver.profileImageUrl!.isNotEmpty)
                      ? NetworkImage(driver.profileImageUrl!)
                      : null,
                  child: (driver.profileImageUrl == null ||
                          driver.profileImageUrl!.isEmpty)
                      ? Icon(
                          LucideIcons.user,
                          size: isDesktop ? 35 : 30,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        driver.taxiOffice,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDriverDetail(
                  context,
                  icon: LucideIcons.car,
                  title: local.translate('car_model'),
                  value: driver.carModel,
                ),
                _buildDriverDetail(
                  context,
                  icon: LucideIcons.car,
                  title: local.translate('plate_number'),
                  value: driver.carPlateNumber,
                ),
                _buildDriverDetail(
                  context,
                  icon: LucideIcons.star,
                  title: local.translate('rating'),
                  value: driver.rating.toStringAsFixed(1),
                ),
                _buildDriverDetail(
                  context,
                  icon: LucideIcons.hash,
                  title: local.translate('number_of_ratings'),
                  value: driver.numberOfRatings.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDetail(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall,
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTripsSection(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return FutureBuilder<List<Trip>>(
      future: _recentTripsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text(
            local.translate('error_loading_trips'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          );
        }

        final trips = snapshot.data ?? [];

        if (trips.isEmpty) {
          return Text(local.translate('no_recent_trips'));
        }

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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trips.take(5).length, // عرض آخر 5 رحلات فقط
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
                            "${local.translate('from')}: ${trip.startLocation.address}",
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            "${local.translate('to')}: ${trip.endLocation.address}",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      trailing: Text(
                        "\$${trip.actualFare.toStringAsFixed(2)}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Driver>(
              future: _driverInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(
                    local.translate('error_loading_driver_info'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  );
                }
                return _buildDriverProfile(context, snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            _buildRecentTripsSection(context),
          ],
        ),
      ),
    );
  }
}
