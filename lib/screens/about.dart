import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart';
// import 'package:taxi_app/providers/theme_provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // احصل على الثيم الحالي

    localizedStrings(String key) => AppLocalizations.of(context).translate(key);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الرئيسي
              Text(
                localizedStrings('about_title'),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // وصف التطبيق
              Text(
                localizedStrings('about_description'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // قسم الميزات
              Text(
                localizedStrings('features_title'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              _buildFeatureCard(context, "💡 ${localizedStrings('feature1')}"),
              _buildFeatureCard(context, "📍 ${localizedStrings('feature2')}"),
              _buildFeatureCard(context, "💳 ${localizedStrings('feature3')}"),
              _buildFeatureCard(context, "🔐 ${localizedStrings('feature4')}"),
              _buildFeatureCard(context, "🤖 ${localizedStrings('feature5')}"),

              const SizedBox(height: 32),

              // لماذا تختارنا؟
              Text(
                localizedStrings('why_choose_title'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                localizedStrings('why_choose_description'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),

              // فريق العمل
              Text(
                localizedStrings('team_title'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              _buildTeamMemberCard(
                context,
                localizedStrings('founder_name'),
                localizedStrings('founder_role'),
                localizedStrings('founder_bio'),
              ),
              _buildTeamMemberCard(
                context,
                localizedStrings('marketing_name'),
                localizedStrings('marketing_role'),
                localizedStrings('marketing_bio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(
      BuildContext context, String name, String role, String bio) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleLarge),
                  Text(role, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(bio, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
