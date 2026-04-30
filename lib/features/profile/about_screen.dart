import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'about'.tr(),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
          child: Column(
            children: [
              // Pro Developer Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    children: [
                      // Background Image with Gradient Overlay
                      Image.asset(
                        'assets/developer.jpg', // User will provide this
                        width: double.infinity,
                        height: 550,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 550,
                          color: Colors.grey[900],
                          child: const Icon(Icons.person_rounded, size: 100, color: Colors.white24),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content on Image
                      Positioned(
                        bottom: 30,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tekalign Haile',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Expert Flutter Developer',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                color: colorScheme.primaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ).animate().fadeIn(delay: 500.ms).moveX(begin: -20, end: 0),
                            const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildSocialIcon(Icons.video_library_rounded, 'YouTube', 'https://www.youtube.com/@programmer360'),
                                    const SizedBox(width: 12),
                                    _buildSocialIcon(Icons.link_rounded, 'LinkedIn', 'https://www.linkedin.com/in/tekalign-haile-975b573a8/'),
                                    const SizedBox(width: 12),
                                    _buildSocialIcon(Icons.alternate_email_rounded, 'Email', 'mailto:tekidevloper@gmail.com'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildStatItem('Subscribers', '233'),
                                    const SizedBox(width: 20),
                                    _buildStatItem('Videos', '25'),
                                    const SizedBox(width: 20),
                                    _buildStatItem('Views', '2.4K+'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Text(
                                      'United States • Joined Nov 2023',
                                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 40),

              // App Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', height: 100),
                    const SizedBox(height: 16),
                    Text(
                      'HameShop',
                      style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Text(
                      'about_app_desc'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(height: 1.6, fontSize: 15),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Admin Section
              _buildAdminCard(context),

              const SizedBox(height: 40),

              // Contact Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'contact_info_title'.tr().toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProContactCard(
                    Icons.alternate_email_rounded,
                    'hamelemalasdesach@gmail.com',
                    'mailto:hamelemalasdesach@gmail.com',
                  ),
                  const SizedBox(height: 12),
                  _buildProContactCard(
                    Icons.phone_iphone_rounded,
                    '+251 979 875 343',
                    'tel:+251979875343',
                  ),
                  const SizedBox(height: 12),
                  _buildProContactCard(
                    Icons.telegram_rounded,
                    '@Hameee40',
                    'https://t.me/Hameee40',
                  ),
                 
                  const SizedBox(height: 12),
                  _buildProContactCard(
                    Icons.link_rounded,
                    'LinkedIn Profile',
                    'https://www.linkedin.com/in/tekalign-haile-975b573a8/',
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).moveY(begin: 30, end: 0),

              const SizedBox(height: 60),

              Text(
                '© 2026 HameShop. Crafted by Tekalign Haile.',
                style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: _getAdminProfileProvider(),
            backgroundColor: Colors.grey,
            child: _buildAdminProfilePlaceholder(context),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hamee Asdsach',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'HameShop Admin Services',
                  style: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Managing operations and user support.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).moveX(begin: 30, end: 0);
  }

  ImageProvider? _getAdminProfileProvider() {
    final user = UserService().currentUser.value;
    // We only care about the admin info here
    // If the currently logged in user is admin, show their image
    // Otherwise, we might need to fetch the admin's image from the server if they are not the current user
    // For now, based on the seed data, the admin has a specific email/role
    
    // Check if the current user is THE admin from seeds
    if (user?.role == UserRole.admin || user?.email == 'tekidevloper@gmail.com') {
      if (user?.profileImage != null) {
        if (user!.profileImage!.startsWith('http')) {
          return CachedNetworkImageProvider(user.profileImage!);
        }
        try {
          String base64Str = user.profileImage!;
          if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
          return MemoryImage(base64Decode(base64Str.trim()));
        } catch (e) {
          debugPrint('Error decoding admin profile image: $e');
        }
      }
    }

    return const AssetImage('assets/admin.jpg');
  }

  Widget? _buildAdminProfilePlaceholder(BuildContext context) {
    final user = UserService().currentUser.value;
    final hasImage = user?.profileImage != null;
    final isAdmin = user?.role == UserRole.admin || user?.email == 'tekidevloper@gmail.com';

    if (isAdmin && hasImage && !user!.profileImage!.startsWith('http')) {
      try {
        String base64Str = user.profileImage!;
        if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
        base64Decode(base64Str.trim());
      } catch (e) {
        return const Icon(Icons.broken_image_rounded, size: 30, color: Colors.white);
      }
    }
    return null;
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildProContactCard(IconData icon, String label, String url) {
    return InkWell(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
