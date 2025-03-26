// CustomAppBar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:taxi_app/providers/language_provider.dart';
import 'package:taxi_app/screens/ProfileScreen.dart';
import 'package:taxi_app/screens/signin_screen.dart';
import 'package:taxi_app/screens/signup_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> hiddenButtons;

  const CustomAppBar({Key? key, this.hiddenButtons = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final theme = Theme.of(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    bool isArabic = languageProvider.locale.languageCode == 'ar';

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      title: Text(
        'TaxiGo',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: theme.colorScheme.onPrimary),
      ),
      actions: [
        // زر تسجيل الدخول كقائمة منسدلة
        if (!hiddenButtons.contains('login'))
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle,
                color: theme.colorScheme.onPrimary, size: 30),
            onSelected: (value) {
              if (value == 'signin') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));
              } else if (value == 'signup') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()));
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'signin',
                child: Text(isArabic ? 'تسجيل الدخول' : 'Sign In'),
              ),
              PopupMenuItem(
                value: 'signup',
                child: Text(isArabic ? 'إنشاء حساب' : 'Sign Up'),
              ),
            ],
          ),

        // زر ملف التعريف
        if (!hiddenButtons.contains('profile'))
          IconButton(
            icon: Icon(Icons.account_circle,
                size: 30, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()));
            },
          ),

        // زر تغيير الثيم باستخدام Provider
        if (!hiddenButtons.contains('theme'))
          IconButton(
            icon: Icon(isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
                color: theme.colorScheme.onPrimary),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),

        // زر تغيير اللغة
        if (!hiddenButtons.contains('language'))
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Locale newLocale =
                  isArabic ? const Locale('en') : const Locale('ar');
              languageProvider.setLocale(newLocale);
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
