import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'theme/theme.dart'; // استيراد الثيم
import 'screens/homepage.dart'; // استيراد الصفحة

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: lightTheme, // استخدام الثيم الفاتح
            darkTheme: darkTheme, // استخدام الثيم الداكن
            themeMode: themeProvider.themeMode, // تحديد الوضع
            home: HomePage(), // الصفحة الرئيسية
          );
        },
      ),
    );
  }
}
