import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/user_service.dart';
import 'auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _userService = UserService();
  bool _obscurePassword = true;
  
  // Password strength tracking
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color _strengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _strengthLabel = '';
        _strengthColor = Colors.transparent;
      });
      return;
    }

    double strength = 0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9!@#\$&*~]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _strengthLabel = 'weak'.tr();
        _strengthColor = Colors.redAccent;
      } else if (strength <= 0.5) {
        _strengthLabel = 'fair'.tr();
        _strengthColor = Colors.orangeAccent;
      } else if (strength <= 0.75) {
        _strengthLabel = 'good'.tr();
        _strengthColor = Colors.blueAccent;
      } else {
        _strengthLabel = 'strong'.tr();
        _strengthColor = Colors.greenAccent;
      }
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final error = await _userService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (error == null) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('registration_success'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
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
        const SnackBar(
          content: Text('Google Sign-In failed'), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.1),
              ),
            ).animate().fadeIn(duration: 1000.ms).scale(),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.15),
              ),
            ).animate().fadeIn(duration: 1200.ms).scale(),
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
                        subtitle: 'Join our exclusive community',
                      ),
                      const SizedBox(height: 40),
                      AuthCard(
                        child: Column(
                          children: [
                            AuthField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              label: 'full_name'.tr(),
                              hint: 'Hame',
                              icon: Icons.person_outline_rounded,
                              onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'enter_name'.tr();
                                return null;
                              },
                            ).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: 20),
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
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) return 'invalid_email'.tr();
                                return null;
                              },
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: 20),
                            AuthField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'password'.tr(),
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              onFieldSubmitted: (_) => _handleRegister(),
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
                            ).animate().fadeIn(delay: 300.ms),
                            
                            // Password Strength Indicator
                            if (_passwordController.text.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: _passwordStrength,
                                          backgroundColor: Colors.white10,
                                          color: _strengthColor,
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _strengthLabel,
                                        style: TextStyle(color: _strengthColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ).animate().fadeIn(),
                              
                            const SizedBox(height: 40),
                            ValueListenableBuilder<bool>(
                              valueListenable: _userService.isLoading,
                              builder: (context, isLoading, _) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: Colors.orange.withOpacity(0.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : Text(
                                            'register'.tr(),
                                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                );
                              },
                            ).animate().fadeIn(delay: 500.ms).scale(),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('already_have_account'.tr(), style: const TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'login_now'.tr(),
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
