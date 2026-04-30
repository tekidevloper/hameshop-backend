import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/banner_service.dart';
import '../../models/banner_model.dart';
import '../widgets/ui_widgets.dart';

class ManageBannersScreen extends StatefulWidget {
  const ManageBannersScreen({super.key});

  @override
  State<ManageBannersScreen> createState() => _ManageBannersScreenState();
}

class _ManageBannersScreenState extends State<ManageBannersScreen> {
  final BannerService _bannerService = BannerService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _bannerService.fetchBanners();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
  
      if (image != null) {
        setState(() => _isUploading = true);
        
        final bytes = await image.readAsBytes();
        
        // Use background isolate to encode large image data to prevent UI freeze/crash
        final base64Image = await compute(base64Encode, bytes);
        
        final result = await _bannerService.addBanner(base64Image);
  
        if (mounted) {
          setState(() => _isUploading = false);
  
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Banner added successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${result['message']}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Banners'),
      ),
      body: ValueListenableBuilder<List<BannerModel>>(
        valueListenable: _bannerService.banners,
        builder: (context, banners, child) {
          if (banners.isEmpty && _bannerService.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (banners.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No banners found'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add First Banner'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: ProductImage(
                            imageUrl: banner.imageUrl,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Banner'),
                                    content: const Text('Are you sure?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _bannerService.deleteBanner(banner.id);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (_isUploading)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _pickAndUploadImage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
