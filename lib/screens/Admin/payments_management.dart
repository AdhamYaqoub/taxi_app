import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentsManagementPage extends StatefulWidget {
  const PaymentsManagementPage({super.key});

  @override
  State<PaymentsManagementPage> createState() => _PaymentsManagementPageState();
}

class _PaymentsManagementPageState extends State<PaymentsManagementPage> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCompletedPayments();
  }

  Future<void> _fetchCompletedPayments() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/api/payments/completed'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _transactions = data['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load payments');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title:
            Text(AppLocalizations.of(context).translate('payments_management')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
                AppLocalizations.of(context).translate('transaction_details')),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _buildTransactionList(),
            const SizedBox(height: 20),
            _buildSectionTitle(
                AppLocalizations.of(context).translate('pricing_and_offers')),
            _buildPricingControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                transaction['status'] == 'completed'
                    ? LucideIcons.checkCircle
                    : LucideIcons.alertTriangle,
                color: transaction['status'] == 'completed'
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(
                  '${AppLocalizations.of(context).translate('trip')} #${transaction['tripId']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${AppLocalizations.of(context).translate('amount')}: \$${transaction['amount']}'),
                  Text(
                      '${AppLocalizations.of(context).translate('date')}: ${_formatDate(transaction['date'])}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(LucideIcons.eye),
                onPressed: () {
                  _showTransactionDetails(context, transaction);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTransactionDetails(BuildContext context, dynamic transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${AppLocalizations.of(context).translate('trip')} #${transaction['tripId']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${AppLocalizations.of(context).translate('user')}: ${transaction['user']}'),
            Text(
                '${AppLocalizations.of(context).translate('driver')}: ${transaction['driver']}'),
            Text(
                '${AppLocalizations.of(context).translate('amount')}: \$${transaction['amount']}'),
            Text(
                '${AppLocalizations.of(context).translate('payment_method')}: ${transaction['paymentMethod']}'),
            Text(
                '${AppLocalizations.of(context).translate('date')}: ${_formatDate(transaction['date'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).translate('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingControls(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(LucideIcons.dollarSign, color: Colors.black),
          title:
              Text(AppLocalizations.of(context).translate('edit_fare_prices')),
          trailing: IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              // وظيفة تعديل الأسعار
            },
          ),
        ),
        ListTile(
          leading: const Icon(LucideIcons.percent, color: Colors.black),
          title: Text(AppLocalizations.of(context)
              .translate('manage_offers_discounts')),
          trailing: IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: () {
              // وظيفة إدارة العروض
            },
          ),
        ),
      ],
    );
  }
}
