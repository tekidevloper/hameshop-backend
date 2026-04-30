import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/theme_service.dart';
import '../../services/user_service.dart';
import '../profile/change_password_screen.dart';
import '../../models/user_model.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  final UserService _userService = UserService();
  bool _notificationsEnabled = true;

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'code': 'am', 'name': 'Amharic', 'native': 'አማርኛ', 'flag': '🇪🇹'},
    {'code': 'or', 'name': 'Oromegna', 'native': 'Afaan Oromoo', 'flag': '🇪🇹'},
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Map<String, String> get _currentLanguage {
    final code = context.locale.languageCode;
    return _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => _languages.first,
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'language'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              ..._languages.map((lang) {
                final isSelected = context.locale.languageCode == lang['code'];
                return ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  title: Text(
                    lang['native']!,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  subtitle: Text(
                    lang['name']!,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded,
                          color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    context.setLocale(Locale(lang['code']!));
                    Navigator.pop(ctx);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _userService.currentUser.value?.role == UserRole.admin;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'settings'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── General ─────────────────────────────────────────────
          _buildSectionHeader('General', Icons.tune_rounded, primaryColor)
              .animate().fadeIn(delay: 50.ms),
          _buildCard([
            // Language
            ListTile(
              leading: _buildIconBox(_currentLanguage['flag']!, null),
              title: Text('language'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text(
                _currentLanguage['native']!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentLanguage['name']!,
                    style: TextStyle(color: primaryColor, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                ],
              ),
              onTap: _showLanguagePicker,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // Theme
            ListTile(
              leading: _buildIconBox(null, Icons.palette_rounded, primaryColor),
              title: Text('theme'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              trailing: ValueListenableBuilder<ThemeMode>(
                valueListenable: _themeService.themeMode,
                builder: (context, mode, child) {
                  return DropdownButton<ThemeMode>(
                    value: mode,
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System', style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light', style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark', style: GoogleFonts.poppins(fontSize: 13)),
                      ),
                    ],
                    onChanged: (newMode) {
                      if (newMode != null) _themeService.setTheme(newMode);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // Notifications
            ListTile(
              leading: _buildIconBox(null, Icons.notifications_rounded, Colors.orange),
              title: Text('notifications'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('enable_notifications'.tr(),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeColor: primaryColor,
                onChanged: _setNotifications,
              ),
            ),
          ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08, end: 0),

          const SizedBox(height: 16),

          // ── Account ──────────────────────────────────────────────
          _buildSectionHeader('Account', Icons.person_rounded, Colors.blue)
              .animate().fadeIn(delay: 150.ms),
          _buildCard([
            // Change Password
            ListTile(
              leading: _buildIconBox(null, Icons.lock_rounded, Colors.indigo),
              title: Text('change_password'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
            ),
          ]).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

          const SizedBox(height: 16),

          // ── About ─────────────────────────────────────────────────
          _buildSectionHeader('About', Icons.info_rounded, Colors.teal)
              .animate().fadeIn(delay: 250.ms),
          _buildCard([
            ListTile(
              leading: _buildIconBox(null, Icons.shopping_bag_rounded, primaryColor),
              title: Text('app_title'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('${'version'.tr()} 1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: _buildIconBox(null, Icons.code_rounded, Colors.deepPurple),
              title: Text('developer_credit'.tr(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: const Text('Tekalign Haile',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ]).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08, end: 0),

          const SizedBox(height: 16),

          // ── Contact Developer ──────────────────────────────────
          _buildSectionHeader('Contact Developer', Icons.contact_mail_rounded, Colors.green)
              .animate().fadeIn(delay: 350.ms),
          _buildCard([
            _buildContactTile(
              icon: Icons.email_rounded,
              color: Colors.red,
              title: 'Email',
              subtitle: 'tekidevloper@gmail.com',
              url: 'mailto:tekidevloper@gmail.com',
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildContactTile(
              icon: Icons.phone_rounded,
              color: Colors.green,
              title: 'Phone',
              subtitle: '0977845135',
              url: 'tel:0977845135',
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildContactTile(
              icon: Icons.telegram,
              color: Colors.blue,
              title: 'Telegram',
              subtitle: '@DevOpsWork1',
              url: 'https://t.me/DevOpsWork1',
              external: true,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildContactTile(
              icon: Icons.video_library_rounded,
              color: Colors.red,
              title: 'YouTube',
              subtitle: '@hell_programmer360',
              url: 'https://www.youtube.com/@hell_programmer360',
              external: true,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildContactTile(
              icon: Icons.work_rounded,
              color: const Color(0xFF0077B5),
              title: 'LinkedIn',
              subtitle: 'Tekalign Haile',
              url: 'https://www.linkedin.com/in/tekalign-haile-975b573a8/',
              external: true,
            ),
          ]).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08, end: 0),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildIconBox(String? emoji, IconData? icon, [Color? color]) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: emoji != null
            ? Text(emoji, style: const TextStyle(fontSize: 20))
            : Icon(icon, size: 20, color: color ?? Colors.grey),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String url,
    bool external = false,
  }) {
    return ListTile(
      leading: _buildIconBox(null, icon, color),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey[400]),
      onTap: () async {
        final uri = Uri.parse(url);
        await launchUrl(
          uri,
          mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault,
        );
      },
    );
  }
}
