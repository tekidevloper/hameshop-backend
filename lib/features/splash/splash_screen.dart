import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 1)); // Reduced from 3s to 1s
    if (!mounted) return;
    
    final userService = UserService();
    if (userService.currentUser.value != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            )
                .animate()
                .fade(duration: 500.ms)
                .scale(delay: 500.ms, duration: 500.ms)
                .then()
                .shake(duration: 500.ms),
            const SizedBox(height: 20),
            Text(
              'HameShop',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms)
                .moveY(begin: 20, end: 0),
          ],
        ),
      ),
    );
  }
}
