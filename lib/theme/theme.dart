import 'package:flutter/material.dart';

// **ThemeData Light**
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Color(0xFFFFC107), // الأصفر الأساسي
    onPrimary: Colors.black, // لون النص فوق الأصفر
    surface: Colors.white, // الخلفية البيضاء
    onSurface: Colors.black87, // لون النص على الخلفية
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFFFC107), // أصفر التكاسي الأساسي
    iconTheme: IconThemeData(color: Colors.black), // أيقونات شريط التطبيق
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
    titleLarge: TextStyle(
        color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  iconTheme: IconThemeData(color: Colors.black87),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFC107),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF5F5F5),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xFFFFC107)),
    ),
  ),
);

// **ThemeData Dark**
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFFFC107), // الأصفر الأساسي
    onPrimary: Colors.black, // لون النص فوق الأصفر
    surface: Color(0xFF212121), // الخلفية السوداء
    onSurface: Colors.white, // لون النص على الخلفية الداكنة
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFFFD54F), // أصفر فاتح
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
        color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  scaffoldBackgroundColor: Color(0xFF212121),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    titleLarge: TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
  ),
  iconTheme: IconThemeData(color: Colors.white70),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFD54F),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF616161),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xFFFFD54F)),
    ),
  ),
);
