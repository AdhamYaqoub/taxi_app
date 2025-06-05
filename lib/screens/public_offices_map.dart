import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taxi_app/models/taxi_office.dart';
import 'package:taxi_app/services/api_office.dart';
import 'package:taxi_app/widgets/office_marker.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicTaxiOfficesMap extends StatefulWidget {
  const PublicTaxiOfficesMap({Key? key}) : super(key: key);

  @override
  _PublicTaxiOfficesMapState createState() => _PublicTaxiOfficesMapState();
}

class _PublicTaxiOfficesMapState extends State<PublicTaxiOfficesMap> {
  final MapController _mapController = MapController();
  List<TaxiOffice> _offices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOffices();
  }

  Future<void> _fetchOffices() async {
    try {
      final response = await ApiService.getPublic(
        endpoint: '/api/admin/offices',
      );

      print('Raw API Response: $response'); // إضافة هذه السطر

      setState(() {
        _offices = (response['data'] as List)
            .map((office) {
              print('Office before parsing: $office'); // طباعة قبل التحويل
              return TaxiOffice.fromJson(office);
            })
            .where((office) =>
                office.location.latitude != 0.0 &&
                office.location.longitude != 0.0)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      // ... باقي الكود ...
    }
  }

  void _showOfficeDetails(TaxiOffice office) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // مهم للمحتوى الطويل
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(office.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _buildInfoItem('العنوان', office.location.address),
              _buildInfoItem('الهاتف', office.contact.phone),
              if (office.workingHours != null)
                _buildInfoItem(
                    'ساعات العمل', office.workingHours!.getFormattedHours()),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => launch("tel://${office.contact.phone}"),
                  child: const Text('اتصال بالمكتب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مكاتب التكاسي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOffices,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                  31.9464, 35.3028), // إحداثيات رام الله كمنطقة افتراضية

              initialZoom: 8.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taxi_app',
              ),
              MarkerLayer(
                markers: _offices
                    .map((office) => Marker(
                          point: office.getLatLng(), // استخدام الدالة الجديدة
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => _showOfficeDetails(office),
                            child: OfficeMarker(office: office),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
