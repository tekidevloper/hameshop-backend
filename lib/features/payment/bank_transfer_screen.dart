import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class BankTransferScreen extends StatefulWidget {
  final double amount;
  final String productName;

  const BankTransferScreen({
    super.key,
    required this.amount,
    required this.productName,
  });

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late final List<Map<String, dynamic>> _banks = [
    {
      'name': 'cbe'.tr(),
      'account': '1000549927096',
      'color': const Color(0xFF6A1B9A),
      'initials': 'CBE',
    },
    {
      'name': 'awash_bank'.tr(),
      'account': 'xxxxxxxxxxx',
      'color': const Color(0xFFEF6C00),
      'initials': 'AB',
    },
    {
      'name': 'dashen_bank'.tr(),
      'account': 'xxxxxxxxxxx',
      'color': const Color(0xFF1565C0),
      'initials': 'DB',
    },
    {
      'name': 'abyssinia_bank'.tr(),
      'account': 'xxxxxxxxxxx',
      'color': const Color(0xFFFDD835),
      'textColor': Colors.black,
      'initials': 'BOA',
    },
    {
      'name': 'bank_of_ethiopia'.tr(),
      'account': 'xxxxxxxxxxx',
      'color': const Color(0xFF1B5E20),
      'initials': 'BE',
    },
  ];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  void _submitPayment() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('upload_image'.tr()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 2500), () {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog();
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80)
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 16),
            Text(
              'success'.tr(),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'order_placed_success'.tr(),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final Uri url = Uri.parse('https://t.me/Hameee40');
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: Text('contact_via_telegram'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close screen
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('continue_shopping'.tr()),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'bank_transfer'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Card
            Card(
              elevation: 8,
              shadowColor: primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    Text(
                      'total_amount'.tr(),
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.amount.toStringAsFixed(2)} ETB',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.productName,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('select_bank'.tr()),
            const SizedBox(height: 16),
            
            ..._banks.map((bank) => _buildBankCard(bank)).toList()
                .animate(interval: 80.ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
            
            _buildSectionTitle('upload_image'.tr()),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _image == null ? Colors.grey.withOpacity(0.3) : primaryColor,
                    width: 2,
                    style: _image == null ? BorderStyle.solid : BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _image != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: FutureBuilder<Uint8List>(
                              future: _image!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  );
                                }
                                return const Center(child: CircularProgressIndicator());
                              },
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.sync_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 64, color: primaryColor.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'choose_from_gallery'.tr(),
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ).animate().fadeIn().scale(delay: 400.ms),
            
            const SizedBox(height: 48),
            
            SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        'submit_request'.tr(),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 500.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBankCard(Map<String, dynamic> bank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: bank['color'],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bank['color'].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              bank['initials'],
              style: TextStyle(
                color: bank['textColor'] ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          bank['name'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            bank['account'],
            style: const TextStyle(
              fontFamily: 'Monospace',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.copy_all_rounded, color: Colors.blue),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: bank['account']));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('copied'.tr()),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(12),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
