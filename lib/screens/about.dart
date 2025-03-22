import 'package:flutter/material.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/widgets/CustomAppBar.dart'; // Import AppLocalizations

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 800;

    // Use AppLocalizations to fetch translated strings
    localizedStrings(String key) => AppLocalizations.of(context).translate(key);

    // Check the current theme (dark or light mode)
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar:CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Text(
                localizedStrings('about_title')!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.yellow.shade700,
                    ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                localizedStrings('about_description')!,
                style: TextStyle(
                  fontSize: 18, 
                  color: isDarkMode ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // Features Section
              Text(
                localizedStrings('features_title')!,
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(context, "💡 ${localizedStrings('feature1')!}", ""),
              _buildFeatureCard(context, "📍 ${localizedStrings('feature2')!}", ""),
              _buildFeatureCard(context, "💳 ${localizedStrings('feature3')!}", ""),
              _buildFeatureCard(context, "🔐 ${localizedStrings('feature4')!}", ""),
              _buildFeatureCard(context, "🤖 ${localizedStrings('feature5')!}", ""),

              const SizedBox(height: 32),

              // "Why Choose Us?" Section
              Text(
                localizedStrings('why_choose_title')!,
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizedStrings('why_choose_description')!,
                style: TextStyle(
                  fontSize: 18, 
                  color: isDarkMode ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 32),

              // Team Section
              Text(
                localizedStrings('team_title')!,
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildTeamMemberCard(
                localizedStrings('founder_name')!,
                localizedStrings('founder_role')!,
                localizedStrings('founder_bio')!,
              ),
              _buildTeamMemberCard(
                localizedStrings('marketing_name')!,
                localizedStrings('marketing_role')!,
                localizedStrings('marketing_bio')!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.yellow.shade700, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: isDarkMode ? const Color.fromARGB(255, 245, 222, 222) : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(String name, String role, String bio) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.yellow.shade700,
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    role,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
