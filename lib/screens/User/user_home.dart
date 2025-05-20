import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/services/trips_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedPaymentMethod = "cash";
  bool hasActiveRide = false;
  Position? currentPosition;
  String? startAddress;
  LatLng? selectedLocation;
  double? distance;
  double? estimatedFare;
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final MapController mapController = MapController();
  bool showMap = false;
  List<Marker> markers = [];
  final double fixedFareRate = 10.0;
  List<dynamic> pendingTrips = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadPendingTrips();
  }

  Future<void> _loadPendingTrips() async {
    setState(() => isLoading = true);
    try {
      final trips = await TripsApi.getPendingUserTrips(widget.userId);
      setState(() => pendingTrips = trips);
    } catch (e) {
      _showSnackBar('فشل في تحميل الرحلات: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancelTrip(int tripId) async {
    try {
      await TripsApi.cancelTrip(tripId);
      _showSnackBar('تم إلغاء الرحلة بنجاح');
      _loadPendingTrips(); // إعادة تحميل القائمة بعد الحذف
    } catch (e) {
      _showSnackBar('فشل في إلغاء الرحلة: $e');
    }
  }

  Future<void> _updateTrip(int tripId, String newStart, String newEnd) async {
    try {
      await TripsApi.updateTrip(
        tripId: tripId,
        startAddress: newStart,
        endAddress: newEnd,
      );

      _showSnackBar(AppLocalizations.of(context).translate('ride_updated'));
      _loadPendingTrips();
    } catch (e) {
      _showSnackBar(
          '${AppLocalizations.of(context).translate('update_failed')}: $e');
    }
  }

  void _showDeleteConfirmation(int tripId) {
    final local = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.translate('confirm_cancellation')),
        content: Text(local.translate('are_you_sure_cancel_ride')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelTrip(tripId);
            },
            child: Text(
              local.translate('confirm'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> trip) {
    final TextEditingController startController =
        TextEditingController(text: trip['startLocation']['address']);
    final TextEditingController endController =
        TextEditingController(text: trip['endLocation']['address']);
    final local = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.translate('edit_ride')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              decoration: InputDecoration(
                labelText: local.translate('start_location'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: endController,
              decoration: InputDecoration(
                labelText: local.translate('end_location'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(local.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              _updateTrip(
                trip['tripId'],
                startController.text,
                endController.text,
              );
              Navigator.pop(context);
            },
            child: Text(local.translate('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('يجب تفعيل خدمة الموقع');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('تم رفض صلاحيات الموقع');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
        startLocationController.text = startAddress ?? "الموقع الحالي";
        markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(position.latitude, position.longitude),
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        );
      });
    } catch (e) {
      _showSnackBar('فشل في الحصول على الموقع: $e');
    }
  }

  void _toggleMap() {
    setState(() {
      showMap = !showMap;
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final firstResult = data[0];
          final lat = double.parse(firstResult['lat']);
          final lon = double.parse(firstResult['lon']);

          _updateSelectedLocation(
              LatLng(lat, lon), firstResult['display_name']);
        }
      }
    } catch (e) {
      _showSnackBar('فشل في البحث: $e');
    }
  }

  void _updateSelectedLocation(LatLng point, String address) {
    setState(() {
      selectedLocation = point;
      endLocationController.text = address;
      markers = [
        Marker(
          width: 40.0,
          height: 40.0,
          point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          child: const Icon(Icons.my_location, color: Colors.blue),
        ),
        Marker(
          width: 40.0,
          height: 40.0,
          point: point,
          child: const Icon(Icons.location_pin, color: Colors.red),
        )
      ];
    });

    mapController.move(point, 15.0);

    // حساب المسافة والأجرة
    distance = _calculateDistance(
      currentPosition!.latitude,
      currentPosition!.longitude,
      point.latitude,
      point.longitude,
    );
    estimatedFare = distance! * fixedFareRate;
  }

  void _selectLocationFromMap(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['display_name'] ?? 'عنوان غير معروف';
        _updateSelectedLocation(point, address);
      }
    } catch (e) {
      _showSnackBar('فشل في الحصول على العنوان: $e');
    }
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  Future<void> _createTrip() async {
    if (currentPosition == null || selectedLocation == null) {
      _showSnackBar('يجب تحديد موقع البداية والنهاية');
      return;
    }

    try {
      await TripsApi.createTrip(
        userId: widget.userId, // استخدام الID من الكونستركتر
        startLocation: {
          'longitude': currentPosition!.longitude,
          'latitude': currentPosition!.latitude,
          'address': startLocationController.text,
        },
        endLocation: {
          'longitude': selectedLocation!.longitude,
          'latitude': selectedLocation!.latitude,
          'address': endLocationController.text,
        },
        distance: distance!,
        paymentMethod: selectedPaymentMethod!, // أضف هذا الحقل
      );

      setState(() {
        showMap = false;
        endLocationController.clear();
        startLocationController.clear();
        searchController.clear();
        _loadPendingTrips();
      });

      _showSnackBar('تم إنشاء الرحلة بنجاح');
    } catch (e) {
      _showSnackBar('فشل في إنشاء الرحلة: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              (kToolbarHeight + MediaQuery.of(context).padding.top),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🚖 ${local.translate('new_ride_request')}",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            _buildLocationInput(
              context,
              "📍 ${local.translate('current_location')}",
              local.translate('enter_your_location'),
              startLocationController,
              null,
            ),
            const SizedBox(height: 10),

            // حقل البحث والوجهة الجديد
            _buildDestinationInput(context),
            const SizedBox(height: 15),

            // عرض الأجرة المقدرة وطريقة الدفع
            _buildEstimateFareAndPayment(context),
            const SizedBox(height: 20),

            // زر طلب الرحلة
            _buildRequestRideButton(context),
            const SizedBox(height: 20),

            // إضافة قسم الرحلات المعلقة
            const SizedBox(height: 20),
            Text(
              "🕒  ${local.translate('pending_requests')}",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildPendingTripsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTripsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pendingTrips.isEmpty) {
      return Text(AppLocalizations.of(context).translate('no_pending_rides'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingTrips.length,
      itemBuilder: (context, index) {
        final trip = pendingTrips[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(
                '${AppLocalizations.of(context).translate('from')}: ${trip['startLocation']['address']}'),
            subtitle: Text(
                '${AppLocalizations.of(context).translate('to')}: ${trip['endLocation']['address']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(trip),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(trip['tripId']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationInput(
    BuildContext context,
    String label,
    String hint,
    TextEditingController controller,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        TextField(
          controller: controller,
          readOnly: onTap != null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: theme.cardColor,
          ),
          onTap: onTap,
        ),
      ],
    );
  }

  Widget _buildDestinationInput(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🎯 ${local.translate('destination')}",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: local.translate('search_location'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.map),
              onPressed: _toggleMap,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onSubmitted: (value) => _searchLocation(value),
        ),
        if (showMap) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentPosition != null
                    ? LatLng(
                        currentPosition!.latitude, currentPosition!.longitude)
                    : const LatLng(31.9454, 35.9284),
                initialZoom: 15.0,
                onTap: (tapPosition, point) => _selectLocationFromMap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEstimateFareAndPayment(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (distance != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("المسافة:", style: theme.textTheme.titleMedium),
                  Text("${distance!.toStringAsFixed(1)} كم",
                      style: theme.textTheme.titleMedium),
                ],
              ),
              const Divider(),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "💰 ${local.translate('fare_estimate')}:",
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  estimatedFare != null
                      ? "${estimatedFare!.toStringAsFixed(2)} ${local.translate('currency')}"
                      : "0 ${local.translate('currency')}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "💳 ${local.translate('payment_method')}:",
                  style: theme.textTheme.titleMedium,
                ),
                DropdownButton<String>(
                  value: selectedPaymentMethod,
                  items: ["cash", "card", "wallet"].map((String method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(local.translate(method)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedPaymentMethod = newValue;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRideButton(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "🚖 ${local.translate('request_ride')}",
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}
