import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_service.dart';
import '../auth/auth_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userService = UserService();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final error = await _userService.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (!mounted) return;

      if (error == null) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('Change Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Protect your account by using a strong password.',
                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 32),
              AuthCard(
                child: Column(
                  children: [
                    AuthField(
                      controller: _oldPasswordController,
                      label: 'Current Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscureOld,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOld ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter current password';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      hint: '••••••••',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter new password';
                        if (value.length < 6) return 'Password too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AuthField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      hint: '••••••••',
                      icon: Icons.lock_reset_rounded,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.white38,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirm new password';
                        if (value != _newPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    ValueListenableBuilder<bool>(
                      valueListenable: _userService.isLoading,
                      builder: (context, isLoading, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleChangePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Update Password',
                                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
