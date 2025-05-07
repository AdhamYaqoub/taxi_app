import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/trip.dart';
import 'package:taxi_app/services/trips_api.dart';
import 'package:geolocator/geolocator.dart'; // أضف هذه المكتبة

class DriverRequestsPage extends StatefulWidget {
  final int driverId;
  const DriverRequestsPage({super.key, required this.driverId});

  @override
  State<DriverRequestsPage> createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  late Future<List<Trip>> _tripsFuture;
  bool _isLoading = true;
  String _currentTab = 'pending'; // 'pending' or 'accepted'
  Position? _currentPosition; // current position of the driver

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // طلب صلاحيات الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمة الموقع غير مفعلة');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('تم رفض صلاحيات الموقع');
        }
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      _loadTrips(); // تحميل الرحلات بعد الحصول على الموقع
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في الحصول على الموقع: $e')),
      );
      // إذا فشل الحصول على الموقع، نحميل الرحلات بدون تصفية
      _loadTrips();
    }
  }

  void _loadTrips() {
    setState(() {
      _isLoading = true;

      if (_currentTab == 'pending') {
        if (_currentPosition != null) {
          final future = TripsApi.getNearbyTrips(
            _currentPosition!.longitude,
            _currentPosition!.latitude,
          );

          _tripsFuture = future.then((data) {
            final String message = data['message'];
            final List<Trip> trips = data['trips'];

            if (message.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              });
            }

            setState(() => _isLoading = false);
            return trips;
          });
        } else {
          _tripsFuture = TripsApi.getPendingTrips().then((trips) {
            setState(() => _isLoading = false);
            return trips;
          });
        }
      } else {
        _tripsFuture = TripsApi.getDriverTripsWithStatus(
          widget.driverId,
          status: 'accepted',
        ).then((trips) {
          setState(() => _isLoading = false);
          return trips;
        });
      }
    });
  }

  Future<void> _handleAcceptTrip(int tripId) async {
    try {
      setState(() => _isLoading = true);
      await TripsApi.acceptTrip(tripId.toString(), widget.driverId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم قبول الرحلة بنجاح')),
      );
      _loadTrips(); // إعادة تحميل الرحلات
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في قبول الرحلة: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRejectTrip(int tripId) async {
    try {
      setState(() => _isLoading = true);
      await TripsApi.rejectTrip(tripId.toString(), widget.driverId);
      _loadTrips();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض الرحلة')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في رفض الرحلة: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStartTrip(int tripId) async {
    try {
      setState(() => _isLoading = true);
      await TripsApi.startTrip(tripId);
      _loadTrips();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم بدء الرحلة')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في بدء الرحلة: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(local.translate('trip_management')),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  local.translate('pending_requests'),
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
              Tab(
                child: Text(
                  local.translate('accepted_trips'),
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
            onTap: (index) {
              setState(() => _currentTab = index == 0 ? 'pending' : 'accepted');
              _loadTrips();
            },
          ),
        ),
        body: TabBarView(
          children: [
            _buildTripsList(theme, local),
            _buildTripsList(theme, local),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList(ThemeData theme, AppLocalizations local) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadTrips();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Trip>>(
              future: _tripsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(local.translate('error_loading_trips')),
                  );
                }

                final trips = snapshot.data ?? [];

                if (trips.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentTab == 'pending'
                              ? LucideIcons.clock
                              : LucideIcons.car,
                          size: 40,
                          // ignore: deprecated_member_use
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentTab == 'pending'
                              ? local.translate('no_pending_requests')
                              : local.translate('no_accepted_trips'),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${local.translate('trip')} #${trip.tripId}",
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            _buildTripDetailRow(
                              icon: LucideIcons.mapPin,
                              label: local.translate('from'),
                              value: trip.startLocation.address,
                            ),
                            _buildTripDetailRow(
                              icon: LucideIcons.mapPin,
                              label: local.translate('to'),
                              value: trip.endLocation.address,
                            ),
                            _buildTripDetailRow(
                              icon: LucideIcons.map,
                              label: local.translate('distance'),
                              value:
                                  "${trip.distance} ${local.translate('km')}",
                            ),
                            _buildTripDetailRow(
                              icon: LucideIcons.clock,
                              label: _currentTab == 'pending'
                                  ? local.translate('requested_at')
                                  : local.translate('accepted_at'),
                              value: _formatDateTime(_currentTab == 'pending'
                                  ? trip.requestedAt
                                  : trip.acceptedAt),
                            ),
                            _buildTripDetailRow(
                                icon: LucideIcons.user,
                                label: local.translate('payment_method'),
                                value: trip.paymentMethod),
                            const SizedBox(height: 16),
                            _currentTab == 'pending'
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(LucideIcons.check),
                                        label: Text(local.translate('accept')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _handleAcceptTrip(trip.tripId),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(LucideIcons.x),
                                        label: Text(local.translate('reject')),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _handleRejectTrip(trip.tripId),
                                      ),
                                    ],
                                  )
                                : ElevatedButton.icon(
                                    icon: const Icon(LucideIcons.play),
                                    label: Text(local.translate('start_trip')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        _handleStartTrip(trip.tripId),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildTripDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // لضبط النص في حال لف
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
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
