import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.withOpacity(0.2),
            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            size: 60,
            color: Colors.orange,
          ),
        ).animate().scale(duration: 600.ms).rotate(begin: -0.1, end: 0),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.white70,
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }
}

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.autofillHints,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30),
            prefixIcon: Icon(icon, color: Colors.orange.withOpacity(0.7)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
