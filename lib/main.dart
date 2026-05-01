import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/theme_service.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'services/banner_service.dart';
import 'services/order_service.dart';

import 'features/profile/change_password_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Firebase is intentionally skipped - not configured for Android yet.
  
  // Load theme preference
  await ThemeService().loadTheme();
  
  // Initialize user service
  await UserService().init();

  // Initial data fetch
  ProductService().fetchProducts();
  BannerService().fetchBanners();
  OrderService().fetchOrders();

  // Global Error Handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // You could log this to a service like Sentry or Firebase Crashlytics here
    debugPrint('Flutter Error: ${details.exception}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Oops! Something went wrong.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We encountered an unexpected error. Please restart the app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => main(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  };

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
        Locale('or'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const HameShopApp(),
    ),
  );
}

class HameShopApp extends StatefulWidget {
  const HameShopApp({super.key});

  @override
  State<HameShopApp> createState() => _HameShopAppState();
}

class _HameShopAppState extends State<HameShopApp> {
  final ThemeService _themeService = ThemeService();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeService.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'HameShop',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/change-password': (context) => const ChangePasswordScreen(),
          },
        );
      },
    );
  }
}
