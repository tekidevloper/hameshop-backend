import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/user_service.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _userService = UserService();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  
  // Animation controller for the shake effect
  int _shakeCounter = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final error = await _userService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (error == null) {
        if (!mounted) return;
        HapticFeedback.lightImpact();
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (!mounted) return;
        setState(() => _shakeCounter++);
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _userService.signInWithGoogle();
    if (success) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Google Sign-In failed'), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    
    final success = await _userService.forgotPassword(_emailController.text.trim());
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_reset_sent'.tr()), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Modern dark slate
      body: Stack(
        children: [
          // Background Gradient Circles for Glassmorphism
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withAlpha(38),
              ),
            ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.5, 0.5)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(25),
              ),
            ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.5, 0.5)),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'HameShop',
                        subtitle: 'Experience Shopping Reimagined',
                      ),
                      const SizedBox(height: 40),
                      AuthCard(
                        child: Column(
                          children: [
                            AuthField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: 'email'.tr(),
                              hint: 'hame@gmail.com',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocus),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'enter_email'.tr();
                                if (!value.contains('@')) return 'invalid_email'.tr();
                                return null;
                              },
                            ).animate().fadeIn(delay: 200.ms).moveX(begin: -20, end: 0),
                            const SizedBox(height: 20),
                            AuthField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'password'.tr(),
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              onFieldSubmitted: (_) => _handleLogin(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  color: Colors.white38,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'enter_password'.tr();
                                if (value.length < 6) return 'password_short'.tr();
                                return null;
                              },
                            ).animate().fadeIn(delay: 400.ms).moveX(begin: -20, end: 0),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        side: const BorderSide(color: Colors.white30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        activeColor: Colors.orange,
                                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('remember_me'.tr(), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _handleForgotPassword,
                                  child: Text(
                                    'forgot_password'.tr(),
                                    style: const TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 500.ms),
                            const SizedBox(height: 32),
                            ValueListenableBuilder<bool>(
                              valueListenable: _userService.isLoading,
                              builder: (context, isLoading, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: Colors.orange.withAlpha(127),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : Text(
                                            'login'.tr(),
                                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ).animate().fadeIn(delay: 600.ms).scale();
                              },
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white10)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('or'.tr(), style: const TextStyle(color: Colors.white30)),
                          ),
                          const Expanded(child: Divider(color: Colors.white10)),
                        ],
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: 32),
                      ValueListenableBuilder<bool>(
                        valueListenable: _userService.isLoading,
                        builder: (context, isLoading, _) {
                          return SizedBox(
                            height: 55,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _handleGoogleSignIn,
                              icon: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png',
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blue),
                              ),
                              label: Text(
                                'Continue with Google',
                                style: GoogleFonts.outfit(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withAlpha(25)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                backgroundColor: Colors.white.withAlpha(5),
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('no_account'.tr(), style: const TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            child: Text(
                              'register_now'.tr(),
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 900.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
