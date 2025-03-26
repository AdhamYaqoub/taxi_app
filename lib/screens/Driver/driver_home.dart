import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:taxi_app/language/localization.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            local.translate('driver_dashboard'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildStats(context),
          ),
          const SizedBox(height: 20),
          _buildRecentTrips(context),
        ],
      ),
    );
  }

  List<Widget> _buildStats(BuildContext context) {
    final local = AppLocalizations.of(context);

    return [
      _buildStatCard(
        context,
        title: local.translate('today_trips'),
        value: "12",
        icon: LucideIcons.car,
      ),
      _buildStatCard(
        context,
        title: local.translate('today_earnings'),
        value: "\$150",
        icon: LucideIcons.dollarSign,
      ),
      _buildStatCard(
        context,
        title: local.translate('ratings'),
        value: "4.8",
        icon: LucideIcons.star,
      ),
      _buildStatCard(
        context,
        title: local.translate('active_hours'),
        value: "8h",
        icon: LucideIcons.clock,
      ),
    ];
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrips(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context);

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
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.dividerColor,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    LucideIcons.car,
                    color: theme.colorScheme.secondary,
                  ),
                  title: Text(
                    "${local.translate('trip')} #${index + 1}",
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    "${local.translate('distance')}: ${(index + 1) * 5} ${local.translate('km')}",
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Text(
                    "\$${(index + 1) * 10}",
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
  }
}
