import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/providers/theme_provider.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeb = MediaQuery.of(context).size.width > 800;
    final local = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text(
                local.translate("support_center"),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.dark
                        ? LucideIcons.sun
                        : LucideIcons.moon,
                    color: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                ),
              ],
            ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.translate("support_center"),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildEmergencyButton(context, local),
              const SizedBox(height: 20),
              _buildSupportOptions(context, local),
              const SizedBox(height: 20),
              _buildFAQSection(context, local),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Emergency action implementation
        },
        icon: Icon(
          LucideIcons.alertCircle,
          color: theme.colorScheme.onError,
        ),
        label: Text(
          local.translate("emergency_button"),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onError,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOptions(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.translate("how_can_we_help"),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildSupportTile(
                context,
                icon: LucideIcons.phoneCall,
                color: Colors.green,
                title: local.translate("call_support"),
                onTap: () {
                  // Call support implementation
                },
              ),
              Divider(height: 1, color: theme.dividerColor),
              _buildSupportTile(
                context,
                icon: LucideIcons.mail,
                color: Colors.blue,
                title: local.translate("send_email"),
                onTap: () {
                  // Email support implementation
                },
              ),
              Divider(height: 1, color: theme.dividerColor),
              _buildSupportTile(
                context,
                icon: LucideIcons.messageCircle,
                color: Colors.orange,
                title: local.translate("chat_with_support"),
                onTap: () {
                  // Chat support implementation
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: theme.cardColor,
    );
  }

  Widget _buildFAQSection(BuildContext context, AppLocalizations local) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(
          local.translate("faq"),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          _buildFAQItem(
            context,
            question: local.translate("cancel_trip"),
            answer: local.translate("cancel_trip_answer"),
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildFAQItem(
            context,
            question: local.translate("forgot_item"),
            answer: local.translate("forgot_item_answer"),
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildFAQItem(
            context,
            question: local.translate("schedule_trip"),
            answer: local.translate("schedule_trip_answer"),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        question,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        answer,
        style: theme.textTheme.bodyMedium,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }
}
