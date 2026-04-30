import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../widgets/ui_widgets.dart';
import 'add_edit_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    // Fetch products if empty or as an initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_productService.products.value.isEmpty) {
        _productService.fetchProducts(refresh: true);
      }
    });
  }

  void _deleteProduct(String id) async {
    final success = await _productService.deleteProduct(id);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _productService.fetchProducts(refresh: true);
  }

  void _navigateToAddEdit({Product? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddEdit(),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: _productService.products,
        builder: (context, products, child) {
          if (products.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No products found')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      imageUrl: product.imageUrl,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.price} ETB | ${product.category}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToAddEdit(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
            ),
          );
        },
      ),
    );
  }
}
