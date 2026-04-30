import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../widgets/ui_widgets.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late String _selectedCategory;
  late TextEditingController _imageUrlController;
  
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isRecommended = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _selectedCategory = widget.product?.category ?? 'Electronics';
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _isRecommended = widget.product?.isRecommended ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (selected != null) {
        final bytes = await selected.readAsBytes();
        
        // Use background isolate to encode image to base64
        // Adding the prefix here to ensure consistency
        final String base64String = await compute(base64Encode, bytes);
        final base64WithPrefix = 'data:image/png;base64,$base64String';
        
        setState(() {
          _imageBytes = bytes;
          _imageUrlController.text = base64WithPrefix;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final productService = ProductService();
      final product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text.isEmpty ? 'https://picsum.photos/300/300' : _imageUrlController.text,
        category: _selectedCategory,
        isRecommended: _isRecommended,
      );

      if (kDebugMode) print('Saving product: ${product.toJson()}');

      bool success;
      if (widget.product == null) {
        if (kDebugMode) print('Calling addProduct...');
        success = await productService.addProduct(product);
      } else {
        if (kDebugMode) print('Calling updateProduct...');
        success = await productService.updateProduct(product);
      }

      if (kDebugMode) print('Save success: $success');

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product == null ? 'Product added successfully' : 'Product updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save product. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview/Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(child: Text('Invalid Image')),
                          ),
                        )
                      : widget.product != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ProductImage(imageUrl: widget.product!.imageUrl),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 50, color: Theme.of(context).primaryColor),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap to select product image', 
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price (ETB)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid price' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: ['Electronics', 'Fashion', 'Sports', 'Books', 'Toys']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              SwitchListTile(
                title: const Text('Recommended Product'),
                value: _isRecommended,
                onChanged: (value) => setState(() => _isRecommended = value),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.product == null ? 'Add Product' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
