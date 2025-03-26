import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class PaymentsManagementPage extends StatelessWidget {
  const PaymentsManagementPage({super.key});

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
            _buildTransactionList(),
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
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(
                index.isEven
                    ? LucideIcons.checkCircle
                    : LucideIcons.alertTriangle,
                color: index.isEven ? Colors.green : Colors.red,
              ),
              title: Text(
                  AppLocalizations.of(context).translate('transaction') +
                      " #${index + 1}"),
              subtitle: Text(index.isEven
                  ? AppLocalizations.of(context)
                      .translate('transaction_success')
                  : AppLocalizations.of(context).translate('payment_failed')),
              trailing: IconButton(
                icon: const Icon(LucideIcons.eye),
                onPressed: () {
                  // وظيفة عرض تفاصيل المعاملة
                },
              ),
            ),
          );
        },
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
