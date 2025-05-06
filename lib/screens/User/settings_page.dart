import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:taxi_app/providers/language_provider.dart';
import 'package:taxi_app/screens/User/setting/profile.dart';
import 'package:taxi_app/screens/User/setting/change_password.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isWeb = MediaQuery.of(context).size.width > 800;
    final local = AppLocalizations.of(context);

    return Scaffold(
      appBar: isWeb
          ? null
          : AppBar(
              backgroundColor: theme.colorScheme.primary,
              title: Text(
                local.translate('settings_title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                local.translate('settings_title'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingsSection(context, 'account_personal_info', [
                _buildSettingsItem(
                  context,
                  'edit_profile',
                  LucideIcons.user,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  context,
                  'change_password',
                  LucideIcons.lock,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),     
              ]),
              _buildSettingsSection(context, 'app_settings', [
                _buildSettingsItem(
                  context,
                  'dark_mode',
                  isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                  () {
                    themeProvider.toggleTheme();
                  },
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: theme.colorScheme.secondary,
                  ),
                ),
                _buildSettingsItem(
                  context,
                  'change_language',
                  LucideIcons.globe,
                  () {
                    languageProvider.setLocale(
                      languageProvider.locale.languageCode == 'ar'
                          ? const Locale('en')
                          : const Locale('ar'),
                    );
                  },
                  trailing: Switch(
                    value: languageProvider.locale.languageCode == 'ar',
                    onChanged: (value) {
                      languageProvider.setLocale(
                        value ? const Locale('ar') : const Locale('en'),
                      );
                    },
                    activeColor: theme.colorScheme.secondary,
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  LucideIcons.logOut,
                  color: theme.colorScheme.onError,
                ),
                label: Text(
                  local.translate('logout'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String titleKey,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context).translate(titleKey),
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
            children: items,
          ),
        ),
        const Divider(thickness: 1, height: 30),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String titleKey,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.colorScheme.secondary,
      ),
      title: Text(
        AppLocalizations.of(context).translate(titleKey),
        style: theme.textTheme.bodyLarge,
      ),
      trailing: trailing ?? 
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
