import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:taxi_app/screens/ProfileScreen.dart';
import 'package:taxi_app/screens/signin_screen.dart';
import 'package:taxi_app/screens/signup_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String selectedLanguage;
  final List<String> hiddenButtons; // قائمة الأزرار المخفية

  const CustomAppBar({
    Key? key,
    required this.selectedLanguage,
    this.hiddenButtons = const [], // قائمة افتراضية فارغة (لا شيء مخفي)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      title: Text(
        selectedLanguage == 'Arabic' ? 'TaxiGo - نظام تكاسي ذكي' : 'TaxiGo - Smart Taxi System',
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary),
      ),
      actions: [
        // ✅ إخفاء زر "تسجيل الدخول" إذا كان ضمن القائمة
        if (!hiddenButtons.contains('login'))
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
            },
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary),
            child: Text(selectedLanguage == 'Arabic' ? 'تسجيل الدخول' : 'Login'),
          ),

        // ✅ إخفاء زر "البروفايل" إذا كان ضمن القائمة
        if (!hiddenButtons.contains('profile'))
          IconButton(
            icon: Icon(Icons.account_circle, size: 30, color: theme.colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),

        // ✅ إخفاء زر "إنشاء حساب" إذا كان ضمن القائمة
        if (!hiddenButtons.contains('signup'))
          OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.onPrimary),
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(selectedLanguage == 'Arabic' ? 'إنشاء حساب' : 'Sign Up'),
          ),

        // ✅ زر التبديل بين الوضع الفاتح والداكن
        if (!hiddenButtons.contains('theme'))
          IconButton(
            icon: Icon(isDarkMode ? Icons.brightness_7 : Icons.brightness_6),
            onPressed: () => themeProvider.toggleTheme(),
          ),

        // ✅ زر تغيير اللغة
        if (!hiddenButtons.contains('language'))
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Navigator.pop(context); // يمكنك استبدال هذه الوظيفة بتغيير اللغة مباشرة
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
