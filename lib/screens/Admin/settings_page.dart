import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:taxi_app/providers/language_provider.dart'; // إضافة استيراد LanguageProvider

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var themeProvider = Provider.of<ThemeProvider>(context);
    var languageProvider =
        Provider.of<LanguageProvider>(context); // إضافة LanguageProvider
    bool isDarkMode =
        themeProvider.themeMode == ThemeMode.system; // معرفة حالة الثيم الحالية

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings_title')),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(
              AppLocalizations.of(context).translate('app_settings'), theme),
          _buildSettingsItem(
            icon: LucideIcons.sliders,
            title: AppLocalizations.of(context).translate('manage_system'),
            subtitle: AppLocalizations.of(context)
                .translate('edit_service_and_zones'),
            onTap: () {},
            theme: theme,
          ),
          _buildSettingsItem(
            icon: LucideIcons.bell,
            title: AppLocalizations.of(context).translate('notifications'),
            subtitle:
                AppLocalizations.of(context).translate('control_notifications'),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
              activeColor: theme.colorScheme.secondary,
            ),
            theme: theme,
          ),
          _buildSettingsItem(
            icon: LucideIcons.moon,
            title: AppLocalizations.of(context).translate('night_mode'),
            subtitle:
                AppLocalizations.of(context).translate('toggle_dark_mode'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeColor: theme.colorScheme.secondary,
            ),
            theme: theme,
          ),
          _buildSettingsItem(
            icon: LucideIcons.globe,
            title: AppLocalizations.of(context).translate('change_language'),
            subtitle: AppLocalizations.of(context)
                .translate('switch_between_arabic_and_english'),
            trailing: Switch(
              value: languageProvider.locale.languageCode ==
                  'ar', // التبديل بين اللغتين
              onChanged: (value) {
                languageProvider.setLocale(value ? Locale('ar') : Locale('en'));
              },
              activeColor: theme.colorScheme.secondary,
            ),
            theme: theme,
          ),
          _buildSectionTitle(
              AppLocalizations.of(context).translate('Security_Privacy'),
              theme),
          _buildSettingsItem(
            icon: LucideIcons.shieldCheck,
            title:
                AppLocalizations.of(context).translate('security_management'),
            subtitle: AppLocalizations.of(context)
                .translate('security_settings_and_account_protection'),
            onTap: () {},
            theme: theme,
          ),
          _buildSettingsItem(
            icon: LucideIcons.key,
            title: AppLocalizations.of(context).translate('change_password'),
            subtitle:
                AppLocalizations.of(context).translate('reset_your_password'),
            onTap: () {},
            theme: theme,
          ),
          _buildSectionTitle(
              AppLocalizations.of(context).translate('Updates_Support'), theme),
          _buildSettingsItem(
            icon: LucideIcons.refreshCcw,
            title: AppLocalizations.of(context).translate('check_for_updates'),
            subtitle: AppLocalizations.of(context)
                .translate('update_to_the_latest_version'),
            onTap: () {},
            theme: theme,
          ),
          _buildSettingsItem(
            icon: LucideIcons.helpCircle,
            title: AppLocalizations.of(context).translate('technical_support'),
            subtitle:
                AppLocalizations.of(context).translate('contact_support_team'),
            onTap: () {},
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyMedium?.color),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    required ThemeData theme,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: theme.cardColor,
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color)),
        subtitle: Text(subtitle,
            style: TextStyle(color: theme.textTheme.bodySmall?.color)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
