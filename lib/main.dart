import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/language/localization.dart';
import 'package:taxi_app/providers/notification_provider.dart';
import 'package:taxi_app/providers/theme_provider.dart';
import 'package:taxi_app/providers/language_provider.dart';
import 'package:taxi_app/screens/homepage.dart';
import 'package:taxi_app/screens/splash_screen.dart';
import 'package:taxi_app/theme/theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 إشعار بالخلفية (Mobile): ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (kIsWeb) {
  //   await Firebase.initializeApp(options: firebaseConfig);
  // } else {
  if (!kIsWeb) {
     await Firebase.initializeApp();
  }
  // }

  await dotenv.load(fileName: "../.env"); // Load environment variables
  // Initialize FCM based on platform
  // if (kIsWeb) {
  //   await _setupWebFCM();
  // } else {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _setupMobileFCM();
  }
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // _setupMobileFCM();
  // }

  runApp(const MyApp());
}

// Web FCM setup (only called when kIsWeb is true)
Future<void> _setupWebFCM() async {
  // Will be implemented in a separate file
}

// Mobile FCM setup
void _setupMobileFCM() async {
  // استماع للإشعارات أثناء عمل التطبيق
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📥 إشعار Mobile (Foreground): ${message.notification?.title}');
  });

  // عند فتح التطبيق من إشعار
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 تم فتح التطبيق من إشعار (Mobile): ${message.notification?.title}');
  });

  // ✅ الحصول على FCM Token
  String? token = await FirebaseMessaging.instance.getToken();
  print("🔑 FCM Token: $token");
}

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   dotenv.load(); // تحميل المتغيرات من .env
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale, // تحديد اللغة من المزود
            supportedLocales: const [
              Locale('en', 'US'), // الإنجليزية
              Locale('ar', 'SA'), // العربية
            ],
            localizationsDelegates: [
              AppLocalizations.delegate, // إضافة AppLocalizations
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SplashScreen(),
            routes: {
              '/home': (context) => HomePage(), // ضيف هذه السطر
            },
          );
        },
      ),
    );
  }
}
