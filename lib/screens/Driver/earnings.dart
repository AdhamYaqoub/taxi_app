import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

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
                local.translate('earnings'),
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
            _buildSectionTitle(context, local.translate('total_earnings')),
            _buildEarningsSummary(context),
            const SizedBox(height: 20),
            _buildSectionTitle(context, local.translate('earnings_details')),
            Expanded(
              child: _buildEarningsDetails(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEarningsSummary(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${local.translate('total_earnings')}:",
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              "\$1,200",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsDetails(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return ListView.separated(
      itemCount: 7,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              LucideIcons.dollarSign,
              color: theme.colorScheme.secondary,
            ),
            title: Text(
              "${local.translate('trip')} #${index + 1}",
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              "${local.translate('date')}: 2023-10-${index + 1}",
              style: theme.textTheme.bodySmall,
            ),
            trailing: Text(
              "\$${(index + 1) * 20}",
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
  }
}
