import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/models/taxi_office.dart';
import 'package:taxi_app/services/api_office.dart';
import 'package:taxi_app/widgets/add_office_dialog.dart';

class TaxiOfficesPage extends StatefulWidget {
  final String token;

  const TaxiOfficesPage({super.key, required this.token});

  @override
  _TaxiOfficesPageState createState() => _TaxiOfficesPageState();
}

class _TaxiOfficesPageState extends State<TaxiOfficesPage> {
  List<TaxiOffice> _offices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get(
        endpoint: '/api/admin/offices',
        token: widget.token,
      );

      if (response['success'] == true) {
        setState(() {
          _offices = (response['data'] as List)
              .map((office) => TaxiOffice.fromJson(office))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewOffice() async {
    final result = await showDialog(
      context: context,
      builder: (context) => AddOfficeDialog(token: widget.token),
    );

    if (result == true) {
      await _loadOffices();
    }
  }

  Widget _buildOfficeCard(TaxiOffice office, ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  office.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Chip(
                  label: Text(
                    '#${office.officeId}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: LucideIcons.mapPin,
              label: AppLocalizations.of(context).translate('address'),
              value: office.location.address,
              theme: theme,
            ),
            _buildInfoRow(
              icon: LucideIcons.phone,
              label: AppLocalizations.of(context).translate('phone'),
              value: office.contact.phone,
              theme: theme,
            ),
            _buildInfoRow(
              icon: LucideIcons.mail,
              label: AppLocalizations.of(context).translate('email'),
              value: office.contact.email,
              theme: theme,
            ),
            if (office.manager != null) ...[
              const Divider(),
              Text(
                AppLocalizations.of(context).translate('manager_info'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: LucideIcons.user,
                label: AppLocalizations.of(context).translate('name'),
                value: office.manager!.fullName,
                theme: theme,
              ),
              _buildInfoRow(
                icon: LucideIcons.phone,
                label: AppLocalizations.of(context).translate('phone'),
                value: office.manager!.phone,
                theme: theme,
              ),
              _buildInfoRow(
                icon: LucideIcons.mail,
                label: AppLocalizations.of(context).translate('email'),
                value: office.manager!.email,
                theme: theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(local.translate('taxi_offices')),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: _addNewOffice,
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: _loadOffices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _offices.isEmpty
                  ? Center(
                      child: Text(local.translate('no_offices_found')),
                    )
                  : ListView.builder(
                      itemCount: _offices.length,
                      itemBuilder: (context, index) =>
                          _buildOfficeCard(_offices[index], theme),
                    ),
    );
  }
}
