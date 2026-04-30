import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hame_shop/features/auth/login_screen.dart';
import 'package:hame_shop/features/splash/splash_screen.dart';
import 'package:hame_shop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  
  testWidgets('App starts with Splash Screen and navigates to Login', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('am')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: const HameShopApp(),
      ),
    );

    // Verify that Splash Screen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('HameShop'), findsOneWidget);

    // Wait for the splash screen duration + animation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that Login Screen is displayed
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
