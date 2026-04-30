import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/user_service.dart';
import '../widgets/ui_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _currentImageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = UserService().currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _currentImageBase64 = user?.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256, // Aggressively reduced to 256px
        maxHeight: 256,
        imageQuality: 50, // Higher compression
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String? imageBase64;
      if (_selectedImageBytes != null) {
        // Move encoding to background isolate to save memory on main thread
        imageBase64 = await compute(base64Encode, _selectedImageBytes!);
      }
      
      final success = await UserService().updateProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        profileImage: imageBase64 ?? _currentImageBase64,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        
        if (success) {
          setState(() {
            _selectedImageBytes = null; // Aggressively release memory
            _selectedImage = null;
          });
          Navigator.pop(context); // Close edit screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          setState(() {
            _selectedImageBytes = null;
            _selectedImage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile. Please try again.')),
          );
        }
      }
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          ClipOval(
            child: _selectedImageBytes != null
                ? Image.memory(
                    _selectedImageBytes!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : ProductImage(
                    imageUrl: _currentImageBase64 ?? '',
                    width: 120,
                    height: 120,
                    placeholder: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 8),
              Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains('@')
                    ? 'Please enter a valid email'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
